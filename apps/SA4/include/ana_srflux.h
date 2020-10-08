      SUBROUTINE ana_srflux (ng, tile, model)
!
!! svn $Id: ana_srflux.h 895 2009-01-12 21:06:20Z kate $
!!======================================================================
!! Copyright (c) 2002-2009 The ROMS/TOMS Group                         !
!!   Licensed under a MIT/X style license                              !
!!   See License_ROMS.txt                                              !
!=======================================================================
!                                                                      !
!  This subroutine sets kinematic surface solar shortwave radiation    !
!  flux "srflx" (degC m/s) using an analytical expression.             !
!                                                                      !
!=======================================================================
!
      USE mod_param
      USE mod_forces
      USE mod_grid
      USE mod_ncparam
!
! Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model

#include "tile.h"
!
      CALL ana_srflux_tile (ng, tile, model,                            &
     &                      LBi, UBi, LBj, UBj,                         &
     &                      IminS, ImaxS, JminS, JmaxS,                 &
     &                      GRID(ng) % lonr,                            &
     &                      GRID(ng) % latr,                            &
#ifdef ALBEDO
     &                      FORCES(ng) % cloud,                         &
     &                      FORCES(ng) % Hair,                          &
     &                      FORCES(ng) % Tair,                          &
     &                      FORCES(ng) % Pair,                          &
#endif
#ifdef ECODYNAMO_SW || defined CICE_SW
     &                      FORCES(ng) % cawdir,                        &
#endif
     &                      FORCES(ng) % srflx)                        
!
! Set analytical header file name used.
!
#ifdef DISTRIBUTE
      IF (Lanafile) THEN
#else
      IF (Lanafile.and.(tile.eq.0)) THEN
#endif
        ANANAME(27)=__FILE__
      END IF

      RETURN
      END SUBROUTINE ana_srflux
!
!***********************************************************************
      SUBROUTINE ana_srflux_tile (ng, tile, model,                      &
     &                            LBi, UBi, LBj, UBj,                   &
     &                            IminS, ImaxS, JminS, JmaxS,           &
     &                            lonr, latr,                           &
#ifdef ALBEDO
     &                            cloud,                                &
     &                            Hair, Tair, Pair,                     &
#endif
# ifdef ECODYNAMO_SW || defined CICE_SW
     &                            cawdir,                               &
# endif
     &                            srflx)
!***********************************************************************
!
      USE mod_param
      USE mod_scalars
!
#ifdef ECODYNAMO_SW
      USE mod_biology
      USE ecodynamocpp_mod
#endif
!
      USE exchange_2d_mod, ONLY : exchange_r2d_tile
#ifdef DISTRIBUTE
      USE mp_exchange_mod, ONLY : mp_exchange2d
#endif
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile, model
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
!
#ifdef ASSUMED_SHAPE
      real(r8), intent(in) :: lonr(LBi:,LBj:)
      real(r8), intent(in) :: latr(LBi:,LBj:)
# ifdef ALBEDO
      real(r8), intent(in) :: cloud(LBi:,LBj:)
#  ifdef ECODYNAMO_SW || defined CICE_SW
      real(r8), intent(in) :: cawdir(LBi:,LBj:)
#  endif
      real(r8), intent(in) :: Hair(LBi:,LBj:)
      real(r8), intent(in) :: Tair(LBi:,LBj:)
      real(r8), intent(in) :: Pair(LBi:,LBj:)
# endif
      real(r8), intent(out) :: srflx(LBi:,LBj:)
#else
      real(r8), intent(in) :: lonr(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: latr(LBi:UBi,LBj:UBj)
# ifdef ALBEDO
      real(r8), intent(in) :: cloud(LBi:UBi,LBj:UBj)
#  ifdef ECODYNAMO_SW || defined CICE_SW
      real(r8), intent(in) :: cawdir(LBi:,LBj:)
#  endif
      real(r8), intent(in) :: Hair(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: Tair(LBi:UBi,LBj:UBj)
      real(r8), intent(in) :: Pair(LBi:UBi,LBj:UBj)
# endif
      real(r8), intent(out) :: srflx(LBi:UBi,LBj:UBj)
#endif
!
!  Local variable declarations.
! 
      integer :: i, j
      real(r8), dimension(8):: my_r_date
#if defined ALBEDO || defined DIURNAL_SRFLUX
      integer :: iday, month, year
      real(r8) :: Dangle, Hangle, LatRad
      real(r8) :: cff1, cff2, hour, yday, tdaysLon
      real(r8) :: LonShift, MyHour, MyDay, MyYear, DaysOfTheYear
      logical :: leap_flag
# ifdef ALBEDO
      real(r8) :: Rsolar, e_sat, vap_p, zenith
# endif
#endif
#if defined GAK1D && !defined ALBEDO
      integer :: iday, month, year
      real(r8) :: hour, yday
#endif
      real(r8) :: cff
#ifdef CICE_SW && defined SPECIFIC_HUMIDITY
      real(r8) :: cosZ, TLATrad, TLONGrad, e, d, sw0
#endif
#include "set_bounds.h"

#if defined ALBEDO || defined DIURNAL_SRFLUX
!
!-----------------------------------------------------------------------
!  Compute shortwave radiation (degC m/s):
!
!  ALBEDO option: Compute shortwave radiation flux using the Laevastu
!                 cloud correction to the Zillman equation for cloudless
!  radiation (Parkinson and Washington 1979, JGR, 84, 311-337).  Notice
!  that flux is scaled from W/m2 to degC m/s by dividing by (rho0*Cp).
!
!  DIURNAL_SRFLUX option: Modulate shortwave radiation SRFLX (which
!                         read and interpolated elsewhere) by the local
!  diurnal cycle (a function of longitude, latitude and day-of-year).
!  This option is provided for cases where SRFLX computed by SET_DATA is
!  an average over >= 24 hours. For "diurnal_srflux" to work ana_srflux
!  must be undefined. If you want a strictly analytical diurnal cycle
!  enter it explicitly at the end of this subroutine or use the "albedo"
!  option.
!
!  For a review of shortwave radiation formulations check:
!
!    Niemela, S., P. Raisanen, and H. Savijarvi, 2001: Comparison of
!      surface radiative flux parameterizations, Part II, Shortwave
!      radiation, Atmos. Res., 58, 141-154.
!
!-----------------------------------------------------------------------
!
!  Assume time is in modified Julian day.  Get hour and year day.
!
      CALL caldate (r_date, tdays(ng), year, yday, month, iday, hour)
!
! ecodynamo KKK
!# if defined ECODYNAMO && defined PLIGHT
#if defined ECODYNAMO || defined CICE_SW
# if defined ECODYNAMO_SW
    LonShift = 15.0 * 24.0 ! Degrees per day
    DO j=JstrR,JendR
        DO i=IstrR,IendR
          MyDay = tdays(ng)+ lonr(i,j) / LonShift !Original one!
          CALL caldate (r_date, MyDay, year, yday, month, iday, hour)
          MyDay = yday; 
          MyHour=hour
          CALL light_new_go(LIGHTOBJ,MyHour,MyDay,latr(i,j),cloud(i,j),   &   
    &                            cawdir(i,j),srflx(i,j))
!Scalling of surface radiation from W/m2 to degC m/s
!          if ((j.EQ.JstrR).AND.(i.EQ.IstrR)) then
!            WRITE(*,*) 'year=',year
!            WRITE(*,*) 'month=',month
!            WRITE(*,*) 'yday=',yday
!            WRITE(*,*) 'hour=',hour
!            WRITE(*,*) 'MyHour=',MyHour
!            WRITE(*,*) 'MyLat=',latr(i,j)
!            WRITE(*,*) 'cloud=',cloud(i,j)
!            WRITE(*,*) 'cawdir=',cawdir(i,j)
!            WRITE(*,*) 'srflx=',srflx(i,j)  
!          end if  
           srflx(i,j)=srflx(i,j)/(rho0*cp)
        ENDDO
    ENDDO
!    WRITE(*,*) 'srflx1=',srflx(IstrR,JstrR)
!    WRITE(*,*) 'month=',month,'MyDay=',MyDay,'hour=',hour,'tdays(ng)=',tdays(ng),'srflx=',srflx(IendR,JendR)*(rho0*cp)
# endif
# if defined CICE_SW && defined SPECIFIC_HUMIDITY
    !=======================================================================
    !
    ! AOMIP shortwave forcing
    ! standard calculation using solar declination angle
    ! then shortwave is reduced using a function of cloud fraction
    ! implemented here as in CICE to make sure surface radiation is  
    ! compatible in ROMS and CICE 
    
    DO j=JstrR,JendR
        DO i=IstrR,IendR
          LonShift = 15.0 * 24.0 ! Degrees per day
          MyDay = tdays(ng)+ lonr(i,j) / LonShift !Original one!
          CALL caldate (r_date, MyDay, year, yday, month, iday, hour)
          MyDay = yday; 
          MyHour=hour
          TLONGrad = lonr(i,j)*deg2rad
          TLATrad = latr(i,j)*deg2rad
          !MyHour = MyHour + 12.0_r8*sin(0.5_r8*TLONGrad)
          Hangle = (12.0_r8 - MyHour)*pi/12.0_r8
          Dangle = 23.44_r8*cos((172._r8-MyDay) &
                 * 2.0_r8*pi/365.00_r8)*deg2rad     ! use dayyr instead of c365???
          cosZ = sin(TLATrad)*sin(Dangle) &
             + cos(TLATrad)*cos(Dangle)*cos(Hangle)
          cosZ = max(cosZ,0.0_r8)
          e = 1.e5*Hair(i,j)/(0.622_r8 + 0.378_r8*Hair(i,j))
          d = (cosZ+2.7_r8)*e*1.e-5_r8+1.085_r8*cosZ+0.1_r8
          sw0 = 1353._r8*cosZ**2/d
          sw0 = max(sw0,0.0_r8)
          ! total downward shortwave 
          srflx(i,j) = sw0*(1.0_r8-0.6_r8*cloud(i,j)**3) 
          srflx(i,j)=srflx(i,j)/(rho0*cp)
        ENDDO
    ENDDO
#  endif
#else
!   Pedro 10/07/2015, 30/01/2016
!
!  Estimate solar declination angle (radians).
!
      Dangle=23.44_r8*COS((172.0_r8-yday)*2.0_r8*pi/365.25_r8)
      Dangle=Dangle*deg2rad
!
!  Compute hour angle (radians).
!
      Hangle=(12.0_r8-hour)*pi/12.0_r8
!
#  ifdef ALBEDO
      Rsolar=Csolar/(rho0*Cp)
#  endif
      DO j=JstrR,JendR
        DO i=IstrR,IendR
!jd - start I think this is wrong. 
!jd!
!jd!  Local daylight is a function of the declination (Dangle) and hour 
!jd!  angle adjusted for the local meridian (Hangle-lonr(i,j)/15.0). 
!jd!  The 15.0 factor is because the sun moves 15 degrees every hour.
!jd! - New
!  Local daylight is a function of the declination (Dangle) and hour 
!  angle adjusted for the local longitude (Hangle-lonr(i,j))
!jd - end
          LatRad=latr(i,j)*deg2rad
          cff1=SIN(LatRad)*SIN(Dangle)
          cff2=COS(LatRad)*COS(Dangle)
#  if defined ALBEDO
!
!  Estimate variation in optical thickness of the atmosphere over
!  the course of a day under cloudless skies (Zillman, 1972). To
!  obtain net incoming shortwave radiation multiply by (1.0-0.6*c**3),
!  where c is the fractional cloud cover.
!
!  The equation for saturation vapor pressure is from Gill (Atmosphere-
!  Ocean Dynamics, pp 606).
!
          srflx(i,j)=0.0_r8
!jd Start original
!jd          zenith=cff1+cff2*COS(Hangle-lonr(i,j)*deg2rad/15.0_r8)
!jd new 
          zenith=cff1+cff2*COS(Hangle-lonr(i,j)*deg2rad)
!jd end
          IF (zenith.gt.0.0_r8) THEN
            cff=(0.7859_r8+0.03477_r8*Tair(i,j))/                     &
     &          (1.0_r8+0.00412_r8*Tair(i,j))
            e_sat=10.0_r8**cff    ! saturation vapor pressure (hPa=mbar)
#   ifdef SPECIFIC_HUMIDITY
!  With this directive specific humidity is input as kg/kg
            vap_p=Pair(i,j)*Hair(i,j)/(0.62197_r8+0.378_r8*Hair(i,j))
#   else
            vap_p=e_sat*Hair(i,j) ! water vapor pressure (hPa=mbar) 
#   endif
            srflx(i,j)=Rsolar*zenith*zenith*                            &
     &                 (1.0_r8-0.6_r8*cloud(i,j)**3)/                   &
     &                 ((zenith+2.7_r8)*vap_p*1.0E-3_r8+                &
     &                  1.085_r8*zenith+0.1_r8)
          END IF
#  elif defined DIURNAL_SRFLUX
!
!  SRFLX is reset on each time step in subroutine SET_DATA which 
!  interpolates values in the forcing file to the current date.
!  This DIURNAL_SRFLUX option is provided so that SRFLX values
!  corresponding to a greater or equal daily average can be modulated
!  by the local length of day to produce a diurnal cycle with the 
!  same daily average as the original data.  This approach assumes 
!  the net effect of clouds is incorporated into the SRFLX data. 
!
!  Normalization factor = INTEGRAL{ABS(a+b*COS(t)) dt} from 0 to 2*pi 
!                       = (a*ARCCOS(-a/b)+SQRT(b**2-a**2))/pi
!  
          IF ((ABS(cff1) + 1.e-8_r8) > ABS(cff2)) THEN
            IF (cff1*cff2.gt.0.0_r8) THEN
              cff=cff1                                 ! All day case
              srflx(i,j)=MAX(0.0_r8,                                    &
     &                       srflx(i,j)/cff*                            &
     &                       (cff1+cff2*COS(Hangle-lonr(i,j)*deg2rad)))
            ELSE
              srflx(i,j)=0.0_r8                        ! All night case
            END IF
          ELSE
            cff=(cff1*ACOS(-cff1/cff2)+SQRT(cff2*cff2-cff1*cff1))/pi
            IF (cff .lt. 10.e-10) THEN
              srflx(i,j)=0.0_r8
            ELSE
            srflx(i,j)=MAX(0.0_r8,                                      &
     &                     srflx(i,j)/cff*                              &
     &                     (cff1+cff2*COS(Hangle-lonr(i,j)*deg2rad)))
            END IF
          END IF
! ifdef albedo, elif diurnal
#  endif
        END DO
      END DO
! ifdef ecodynamo & plight, else
# endif
! ifdef albedo or diurnal
#else
!
!-----------------------------------------------------------------------
!  Set incoming solar shortwave radiation (degC m/s).  Usually, the
!  shortwave radiation from input files is Watts/m2 and then converted
!  to degC m/s by multiplying by conversion factor 1/(rho0*Cp) during
!  reading (Fscale). However, we are already inside ROMS kernel here
!  and all the fluxes are kinematic so shortwave radiation units need
!  to be degC m/s.
!-----------------------------------------------------------------------
!
      cff=1.0_r8/(rho0*cp)
# if defined UPWELLING
      DO j=JstrR,JendR
        DO i=IstrR,IendR
          srflx(i,j)=cff*150.0_r8
        END DO
      END DO
#  elif defined GAK1D
!  Eyeball fit to COADS climatological shortwave radiation near GAK1
      CALL caldate (r_date, tdays(ng), year, yday, month, iday, hour)
      cff = ( 41.0_r8 - 38.0_r8                                         &
     &        * COS( (yday-9.0_r8) * 2.21_r8 * pi / 360.0_r8 ) )        &
     &        / (rho0*Cp*0.394848_r8)
      DO j=JstrR,JendR
        DO i=IstrR,IendR
          srflx(i,j)=cff
        END DO
      END DO
# else
      DO j=JstrR,JendR
        DO i=IstrR,IendR
          srflx(i,j)=0.0_r8
        END DO
      END DO
# endif
#endif
!WRITE(*,*) 'srflx2=',srflx(IstrR,JstrR)
IF (EWperiodic(ng).or.NSperiodic(ng)) THEN
      CALL exchange_r2d_tile (ng, tile,                                 &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        srflx)
END IF
!WRITE(*,*) 'srflx3=',srflx(IstrR,JstrR)
#ifdef DISTRIBUTE
      CALL mp_exchange2d (ng, tile, model, 1,                           &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints, EWperiodic(ng), NSperiodic(ng),         &
     &                    srflx)
#endif
!WRITE(*,*) 'srflx4=',srflx(IstrR,JstrR)
      RETURN
      END SUBROUTINE ana_srflux_tile
