PROGRAM bry_from_clim
! Program to obtain boundary conditions from climatology file

! Define if ice variables are available on climfile (ICE_IN) and/or ice variables are wanted on bryfile
!#define ICE_IN
!#undef ICE_IN
!#define ICE_OUT
!#undef ICE_OUT

!#if !defined ICE_OUT
!# undef ICE_IN
!#endif

use netcdf

implicit none

INTEGER SaltVarId, TempVarId, UVarId, VVarId
INTEGER ZetaVarId, UbarVarId, VbarVarId
INTEGER AiceVarId, HiceVarId, HsnoVarId, UiceVarId, ViceVarId
INTEGER TiceVarId, SfwatVarId, AgeiceVarId
INTEGER Sig11VarId, Sig22VarId, Sig12VarId

INTEGER Salt_westVarId, Salt_eastVarId, Salt_southVarId, Salt_northVarId
INTEGER Temp_westVarId, Temp_eastVarId, Temp_southVarId, Temp_northVarId
INTEGER U_westVarId, U_eastVarId, U_southVarId, U_northVarId
INTEGER V_westVarId, V_eastVarId, V_southVarId, V_northVarId
INTEGER Zeta_westVarId, Zeta_eastVarId, Zeta_southVarId, Zeta_northVarId
INTEGER Ubar_westVarId, Ubar_eastVarId, Ubar_southVarId, Ubar_northVarId
INTEGER Vbar_westVarId, Vbar_eastVarId, Vbar_southVarId, Vbar_northVarId
!#ifdef ICE_OUT
INTEGER Aice_westVarId, Aice_eastVarId, Aice_southVarId, Aice_northVarId
INTEGER Hice_westVarId, Hice_eastVarId, Hice_southVarId, Hice_northVarId
INTEGER Hsno_westVarId, Hsno_eastVarId, Hsno_southVarId, Hsno_northVarId
INTEGER Uice_westVarId, Uice_eastVarId, Uice_southVarId, Uice_northVarId
INTEGER Vice_westVarId, Vice_eastVarId, Vice_southVarId, Vice_northVarId
INTEGER Tice_westVarId, Tice_eastVarId, Tice_southVarId, Tice_northVarId
INTEGER Sfwat_westVarId, Sfwat_eastVarId, Sfwat_southVarId, Sfwat_northVarId
INTEGER Ageice_westVarId, Ageice_eastVarId, Ageice_southVarId, Ageice_northVarId
INTEGER Sig11_westVarId, Sig11_eastVarId, Sig11_southVarId, Sig11_northVarId
INTEGER Sig22_westVarId, Sig22_eastVarId, Sig22_southVarId, Sig22_northVarId
INTEGER Sig12_westVarId, Sig12_eastVarId, Sig12_southVarId, Sig12_northVarId
!#endif
INTEGER Bry_timeVarId, Clim_timeVarId, zBry_timeVarId

INTEGER XiDimID, EtaDimID, SDimId, TimeDimId, Lp, Mp, L, M, N, ntime, ztime, zTimeDimId
INTEGER XiRhoDimId, EtaRhoDimId
INTEGER dim_xi_rho, dim_eta_rho, dim_xi_u, dim_eta_u, dim_xi_v, dim_eta_v, dim_s_rho
INTEGER dim_time, dim_ztime
INTEGER status, nc_clim, nc

INTEGER itime
REAL time

REAL, ALLOCATABLE, DIMENSION(:,:,:) :: salt, temp, u, v
REAL, ALLOCATABLE, DIMENSION(:,:) :: zeta, ubar, vbar
!#ifdef ICE_OUT
REAL, ALLOCATABLE, DIMENSION(:,:) :: aice, hice, hsno, uice, vice
REAL, ALLOCATABLE, DIMENSION(:,:) :: tice, sfwat, ageice, sig11, sig22, sig12
!#endif
!#ifdef ICE_OUT
REAL, ALLOCATABLE, DIMENSION(:) :: aice_west, aice_east, aice_south, aice_north
REAL, ALLOCATABLE, DIMENSION(:) :: hice_west, hice_east, hice_south, hice_north
REAL, ALLOCATABLE, DIMENSION(:) :: hsno_west, hsno_east, hsno_south, hsno_north
REAL, ALLOCATABLE, DIMENSION(:) :: uice_west, uice_east, uice_south, uice_north
REAL, ALLOCATABLE, DIMENSION(:) :: vice_west, vice_east, vice_south, vice_north
REAL, ALLOCATABLE, DIMENSION(:) :: tice_west, tice_east, tice_south, tice_north
REAL, ALLOCATABLE, DIMENSION(:) :: sfwat_west, sfwat_east, sfwat_south, sfwat_north
REAL, ALLOCATABLE, DIMENSION(:) :: ageice_west, ageice_east, ageice_south, ageice_north
REAL, ALLOCATABLE, DIMENSION(:) :: sig11_west, sig11_east, sig11_south, sig11_north
REAL, ALLOCATABLE, DIMENSION(:) :: sig22_west, sig22_east, sig22_south, sig22_north
REAL, ALLOCATABLE, DIMENSION(:) :: sig12_west, sig12_east, sig12_south, sig12_north
!#endif
REAL, ALLOCATABLE, DIMENSION(:,:) :: salt_west, salt_east, salt_south, salt_north
REAL, ALLOCATABLE, DIMENSION(:,:) :: temp_west, temp_east, temp_south, temp_north
REAL, ALLOCATABLE, DIMENSION(:,:) :: u_west, u_east, u_south, u_north
REAL, ALLOCATABLE, DIMENSION(:,:) :: v_west, v_east, v_south, v_north
REAL, ALLOCATABLE, DIMENSION(:) :: zeta_west, zeta_east, zeta_south, zeta_north
REAL, ALLOCATABLE, DIMENSION(:) :: ubar_west, ubar_east, ubar_south, ubar_north
REAL, ALLOCATABLE, DIMENSION(:) :: vbar_west, vbar_east, vbar_south, vbar_north
CHARACTER*80 climfile, bryfile

WRITE(6,'(A)',ADVANCE='NO') "Name of climfile: "
READ(5,'(A)') climfile
WRITE(6,'(A)',ADVANCE='NO') "Name of boundary file: "
READ(5,'(A)') bryfile

write(*,*) 'Starting - ', TRIM(climfile), TRIM(bryfile)
! Get info on climatology file
status = nf90_open(TRIM(climfile),nf90_nowrite,nc_clim)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_dimid(nc_clim, "xi_rho", XiDimID)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_dimid(nc_clim, "eta_rho", EtaDimID)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_dimid(nc_clim, "s_rho", SDimID)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_dimid(nc_clim, "clim_time", TimeDimID)
!status = nf90_inq_dimid(nc_clim, "time", TimeDimID)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_dimid(nc_clim, "zeta_time", zTimeDimID)
if(status /= nf90_NoErr) status = nf90_inq_dimid(nc_clim, "clim_time", zTimeDimID)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_Inquire_Dimension(nc_clim,XiDimID,len = Lp)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_Inquire_Dimension(nc_clim,EtaDimID,len = Mp)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_Inquire_Dimension(nc_clim,SDimID,len = N)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_Inquire_Dimension(nc_clim,TimeDimID,len = ntime)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_Inquire_Dimension(nc_clim,zTimeDimID,len = ztime)
if(status /= nf90_NoErr) call handle_err(status)

L = Lp-1
M = Mp-1

write(*,*) 'Lp = ',Lp,',  Mp = ',Mp,',  N = ',N,',  ntime = ',ntime,',  ztime = ',ztime

ALLOCATE(salt(Lp,Mp,N))
ALLOCATE(temp(Lp,Mp,N))
ALLOCATE(u(L,Mp,N))
ALLOCATE(v(Lp,M,N))
ALLOCATE(zeta(Lp,Mp))
ALLOCATE(ubar(L,Mp))
ALLOCATE(vbar(Lp,M))
!#ifdef ICE_OUT
ALLOCATE(aice(Lp,Mp))
ALLOCATE(hice(Lp,Mp))
ALLOCATE(hsno(Lp,Mp))
ALLOCATE(uice(L,Mp))
ALLOCATE(vice(Lp,M))
ALLOCATE(tice(Lp,Mp))
ALLOCATE(sfwat(Lp,Mp))
ALLOCATE(ageice(Lp,Mp))
ALLOCATE(sig11(Lp,Mp))
ALLOCATE(sig22(Lp,Mp))
ALLOCATE(sig12(Lp,Mp))
!#endif
ALLOCATE(salt_west(Mp,N))
ALLOCATE(salt_east(Mp,N))
ALLOCATE(salt_south(Lp,N))
ALLOCATE(salt_north(Lp,N))
ALLOCATE(temp_west(Mp,N))
ALLOCATE(temp_east(Mp,N))
ALLOCATE(temp_south(Lp,N))
ALLOCATE(temp_north(Lp,N))
ALLOCATE(u_west(Mp,N))
ALLOCATE(u_east(Mp,N))
ALLOCATE(u_south(L,N))
ALLOCATE(u_north(L,N))
ALLOCATE(v_west(M,N))
ALLOCATE(v_east(M,N))
ALLOCATE(v_south(Lp,N))
ALLOCATE(v_north(Lp,N))
ALLOCATE(zeta_west(Mp))
ALLOCATE(zeta_east(Mp))
ALLOCATE(zeta_south(Lp))
ALLOCATE(zeta_north(Lp))
ALLOCATE(ubar_west(Mp))
ALLOCATE(ubar_east(Mp))
ALLOCATE(ubar_south(L))
ALLOCATE(ubar_north(L))
ALLOCATE(vbar_west(M))
ALLOCATE(vbar_east(M))
ALLOCATE(vbar_south(Lp))
ALLOCATE(vbar_north(Lp))
!#ifdef ICE_OUT
ALLOCATE(aice_west(Mp))
ALLOCATE(aice_east(Mp))
ALLOCATE(aice_south(Lp))
ALLOCATE(aice_north(Lp))
ALLOCATE(hice_west(Mp))
ALLOCATE(hice_east(Mp))
ALLOCATE(hice_south(Lp))
ALLOCATE(hice_north(Lp))
ALLOCATE(hsno_west(Mp))
ALLOCATE(hsno_east(Mp))
ALLOCATE(hsno_south(Lp))
ALLOCATE(hsno_north(Lp))
ALLOCATE(uice_west(Mp))
ALLOCATE(uice_east(Mp))
ALLOCATE(uice_south(L))
ALLOCATE(uice_north(L))
ALLOCATE(vice_west(M))
ALLOCATE(vice_east(M))
ALLOCATE(vice_south(Lp))
ALLOCATE(vice_north(Lp))
ALLOCATE(tice_west(Mp))
ALLOCATE(tice_east(Mp))
ALLOCATE(tice_south(Lp))
ALLOCATE(tice_north(Lp))
ALLOCATE(sfwat_west(Mp))
ALLOCATE(sfwat_east(Mp))
ALLOCATE(sfwat_south(Lp))
ALLOCATE(sfwat_north(Lp))
ALLOCATE(ageice_west(Mp))
ALLOCATE(ageice_east(Mp))
ALLOCATE(ageice_south(Lp))
ALLOCATE(ageice_north(Lp))
ALLOCATE(sig11_west(Mp))
ALLOCATE(sig11_east(Mp))
ALLOCATE(sig11_south(Lp))
ALLOCATE(sig11_north(Lp))
ALLOCATE(sig22_west(Mp))
ALLOCATE(sig22_east(Mp))
ALLOCATE(sig22_south(Lp))
ALLOCATE(sig22_north(Lp))
ALLOCATE(sig12_west(Mp))
ALLOCATE(sig12_east(Mp))
ALLOCATE(sig12_south(Lp))
ALLOCATE(sig12_north(Lp))
!#endif
! Get var ids in climatology file

status = nf90_inq_varid(nc_clim, "salt",SaltVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_varid(nc_clim, "temp",TempVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_varid(nc_clim, "u",UVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_varid(nc_clim, "v",VVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_varid(nc_clim, "newzeta",ZetaVarId)
if(status /= nf90_NoErr) status = nf90_inq_varid(nc_clim, "zeta",ZetaVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_varid(nc_clim, "ubar",UbarVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_inq_varid(nc_clim, "vbar",VbarVarId)
if(status /= nf90_NoErr) call handle_err(status)
! !#ifdef ICE_IN
write (*,*) 'reading ice-vars'
status = nf90_inq_varid(nc_clim, "aice",AiceVarId)
if(status /= nf90_NoErr) print *,"aice not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "hice",HiceVarId)
if(status /= nf90_NoErr) print *,"hice not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "snow_thick",HsnoVarId)
if(status /= nf90_NoErr) print *,"snow_thick not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "uice",UiceVarId)
if(status /= nf90_NoErr) print *,"uice not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "vice",ViceVarId)
if(status /= nf90_NoErr) print *,"vice not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "ti",TiceVarId)
if(status /= nf90_NoErr) print *,"ti not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "sfwat",SfwatVarId)
if(status /= nf90_NoErr) print *,"sfwat not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "ageice",AgeiceVarId)
if(status /= nf90_NoErr) print *,"ageice not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "sig11",Sig11VarId)
if(status /= nf90_NoErr) print *,"sig11 not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "sig22",Sig22VarId)
if(status /= nf90_NoErr) print *,"sig22 not present on clim-file..." !call handle_err(status)
status = nf90_inq_varid(nc_clim, "sig12",Sig12VarId)
if(status /= nf90_NoErr) print *,"sig12 not present on clim-file..." !call handle_err(status)
! !#endif
status = nf90_inq_varid(nc_clim, "clim_time",Clim_timeVarId)
if(status /= nf90_NoErr) call handle_err(status)

! ------------------------------------------------------                        
! Prepare output netCDF file                                                    
status = nf90_create(trim(bryfile),nf90_clobber,nc)
if(status /= nf90_NoErr) call handle_err(status)

!                                                                               
! Define dimensions                                                             
!                                   
status = nf90_def_dim(nc,'xi_rho',Lp,dim_xi_rho)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_def_dim(nc,'eta_rho',Mp,dim_eta_rho)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_def_dim(nc,'xi_u',L,dim_xi_u)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_def_dim(nc,'eta_u',Mp,dim_eta_u)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_def_dim(nc,'xi_v',Lp,dim_xi_v)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_def_dim(nc,'eta_v',M,dim_eta_v)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_def_dim(nc,'s_rho',N,dim_s_rho)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_def_dim(nc,'bry_time',nf90_unlimited,dim_time)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_def_dim(nc,'zbry_time',ztime,dim_ztime)
if(status /= nf90_NoErr) call handle_err(status)
!                                                                               
! Define variables and attributes                  
!                                
! Global attributes
!
status = nf90_put_att(nc,nf90_global,'type','ROMS/TOMS boundary file')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,nf90_global,'title','ROMS fine-scale simulation')
if(status /= nf90_NoErr) call handle_err(status)
!status = nf90_put_att(nc,nf90_global,'history','From ROMS simulation')
!if(status /= nf90_NoErr) call handle_err(status)
!
! Variables and variable attributes
!
status = nf90_def_var(nc,'bry_time',nf90_double,dim_time,Bry_timeVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Bry_timeVarId,'long_name','open boundary conditions time')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Bry_timeVarId,'units','day of year')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Bry_timeVarId,'field','time, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
!status = nf90_put_att(nc,Bry_timeVarId,'cycle_length',365.25)
!status = nf90_put_att(nc,Bry_timeVarId,'cycle_length',365.0)
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'zbry_time',nf90_double,dim_ztime,zBry_timeVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Bry_timeVarId,'long_name','open boundary conditions time')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Bry_timeVarId,'units','day of year')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Bry_timeVarId,'field','time, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
!status = nf90_put_att(nc,Bry_timeVarId,'cycle_length',365.25)
!status = nf90_put_att(nc,Bry_timeVarId,'cycle_length',365.0)
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'salt_west',nf90_float,                           &
         (/dim_eta_rho, dim_s_rho, dim_time/),Salt_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_westVarId,'long_name',                      &
         'salinity western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_westVarId,'units',' ')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_westVarId,'field',                          &
          'salt_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'salt_east',nf90_float,                           &
         (/dim_eta_rho, dim_s_rho, dim_time/),Salt_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_eastVarId,'long_name',                      &
         'salinity eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_eastVarId,'units',' ')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_eastVarId,'field',                          &
          'salt_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'salt_south',nf90_float,                          &
         (/dim_xi_rho, dim_s_rho, dim_time/),Salt_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_southVarId,'long_name',                      &
         'salinity southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_southVarId,'units',' ')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_southVarId,'field',                          &
          'salt_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'salt_north',nf90_float,                          &
         (/dim_xi_rho, dim_s_rho, dim_time/),Salt_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_northVarId,'long_name',                      &
         'salinity northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_northVarId,'units',' ')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_northVarId,'field',                          &
          'salt_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Salt_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'temp_west',nf90_float,                           &
         (/dim_eta_rho, dim_s_rho, dim_time/),Temp_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_westVarId,'long_name',                      &
         'potential temperature western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_westVarId,'units','degree Celsius')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_westVarId,'field',                          &
          'temp_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'temp_east',nf90_float,                           &
         (/dim_eta_rho, dim_s_rho, dim_time/),Temp_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_eastVarId,'long_name',                      &
         'potential temperature eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_eastVarId,'units','degree Celsius')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_eastVarId,'field',                          &
          'temp_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'temp_south',nf90_float,                          &
         (/dim_xi_rho, dim_s_rho, dim_time/),Temp_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_southVarId,'long_name',                     &
         'potential temperature southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_southVarId,'units','degree Celsius')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_southVarId,'field',                         &
          'temp_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'temp_north',nf90_float,                          &
         (/dim_xi_rho, dim_s_rho, dim_time/),Temp_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_northVarId,'long_name',                     &
         'potential temperature northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_northVarId,'units','degree Celsius')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_northVarId,'field',                      &
          'temp_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Temp_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'u_west',nf90_float,                           &
         (/dim_eta_rho, dim_s_rho, dim_time/),U_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_westVarId,'long_name',                      &
         '3D u-momentum western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_westVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_westVarId,'field',                          &
          'u_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'u_east',nf90_float,                           &
         (/dim_eta_rho, dim_s_rho, dim_time/),U_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_eastVarId,'long_name',                      &
         '3D u-momentum eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_eastVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_eastVarId,'field',                          &
          'u_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'u_south',nf90_float,                          &
         (/dim_xi_u, dim_s_rho, dim_time/),U_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_southVarId,'long_name',                      &
         '3D u-momentum southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_southVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_southVarId,'field',                          &
          'u_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'u_north',nf90_float,                          &
         (/dim_xi_u, dim_s_rho, dim_time/),U_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_northVarId,'long_name',                      &
         '3D u-momentum northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_northVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_northVarId,'field',                          &
          'u_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,U_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'v_west',nf90_float,                           &
         (/dim_eta_v, dim_s_rho, dim_time/),V_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_westVarId,'long_name',                      &
         '3D v-momentum western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_westVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_westVarId,'field',                          &
          'v_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'v_east',nf90_float,                           &
         (/dim_eta_v, dim_s_rho, dim_time/),V_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_eastVarId,'long_name',                      &
         '3D v-momentum eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_eastVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_eastVarId,'field',                          &
          'v_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'v_south',nf90_float,                          &
         (/dim_xi_rho, dim_s_rho, dim_time/),V_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_southVarId,'long_name',                      &
         '3D v-momentum southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_southVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_southVarId,'field',                          &
          'v_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'v_north',nf90_float,                          &
         (/dim_xi_rho, dim_s_rho, dim_time/),V_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_northVarId,'long_name',                      &
         '3D v-momentum northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_northVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_northVarId,'field',                          &
          'v_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,V_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'zeta_west',nf90_float,                           &
         (/dim_eta_rho, dim_ztime/),Zeta_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_westVarId,'long_name',                      &
         'free-surface western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_westVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_westVarId,'field',                          &
          'zeta_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_westVarId,'time','zbry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'zeta_east',nf90_float,                           &
         (/dim_eta_rho, dim_ztime/),Zeta_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_eastVarId,'long_name',                      &
         'free-surface eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_eastVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_eastVarId,'field',                          &
          'zeta_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_eastVarId,'time','zbry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'zeta_south',nf90_float,                          &
         (/dim_xi_rho,  dim_ztime/),Zeta_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_southVarId,'long_name',                      &
         'free-surface southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_southVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_southVarId,'field',                          &
          'zeta_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_southVarId,'time','zbry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'zeta_north',nf90_float,                          &
         (/dim_xi_rho,  dim_ztime/),Zeta_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_northVarId,'long_name',                      &
         'free-surface northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_northVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_northVarId,'field',                          &
          'zeta_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Zeta_northVarId,'time','zbry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ubar_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Ubar_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_westVarId,'long_name',                      &
         '2D u-momentum western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_westVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_westVarId,'field',                          &
          'ubar_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ubar_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Ubar_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_eastVarId,'long_name',                      &
         '2D u-momentum eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_eastVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_eastVarId,'field',                          &
          'ubar_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ubar_south',nf90_float,                          &
         (/dim_xi_u,  dim_time/),Ubar_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_southVarId,'long_name',                      &
         '2D u-momentum southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_southVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_southVarId,'field',                          &
          'ubar_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ubar_north',nf90_float,                          &
         (/dim_xi_u,  dim_time/),Ubar_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_northVarId,'long_name',                      &
         '2D u-momentum northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_northVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_northVarId,'field',                          &
          'ubar_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ubar_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'vbar_west',nf90_float,                           &
         (/dim_eta_v, dim_time/),Vbar_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_westVarId,'long_name',                      &
         '2D v-momentum western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_westVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_westVarId,'field',                          &
          'vbar_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'vbar_east',nf90_float,                           &
         (/dim_eta_v, dim_time/),Vbar_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_eastVarId,'long_name',                      &
         '2D v-momentum eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_eastVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_eastVarId,'field',                          &
          'vbar_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'vbar_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Vbar_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_southVarId,'long_name',                      &
         '2D v-momentum southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_southVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_southVarId,'field',                          &
          'vbar_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'vbar_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Vbar_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_northVarId,'long_name',                      &
         '2D v-momentum northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_northVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_northVarId,'field',                          &
          'vbar_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vbar_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

! !#ifdef ICE_OUT
status = nf90_def_var(nc,'aice_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Aice_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_westVarId,'long_name',                      &
         'ice concentration western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_westVarId,'units',' ')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_westVarId,'field',                          &
          'aice_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'aice_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Aice_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_eastVarId,'long_name',                      &
         'ice concentration eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_eastVarId,'units',' ')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_eastVarId,'field',                          &
          'aice_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'aice_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Aice_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_southVarId,'long_name',                      &
         'ice concentration southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_southVarId,'units',' ')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_southVarId,'field',                          &
          'aice_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'aice_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Aice_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_northVarId,'long_name',                      &
         'ice concentration northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_northVarId,'units',' ')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_northVarId,'field',                          &
          'aice_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Aice_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'hice_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Hice_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_westVarId,'long_name',                      &
         'ice thickness western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_westVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_westVarId,'field',                          &
          'hice_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'hice_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Hice_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_eastVarId,'long_name',                      &
         'ice thickness eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_eastVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_eastVarId,'field',                          &
          'hice_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'hice_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Hice_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_southVarId,'long_name',                      &
         'ice thickness southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_southVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_southVarId,'field',                          &
          'hice_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'hice_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Hice_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_northVarId,'long_name',                      &
         'ice thickness northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_northVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_northVarId,'field',                          &
          'hice_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hice_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'uice_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Uice_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_westVarId,'long_name',                      &
         '2D ice u-momentum western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_westVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_westVarId,'field',                          &
          'uice_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'uice_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Uice_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_eastVarId,'long_name',                      &
         '2D ice u-momentum eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_eastVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_eastVarId,'field',                          &
          'uice_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'uice_south',nf90_float,                          &
         (/dim_xi_u,  dim_time/),Uice_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_southVarId,'long_name',                      &
         '2D ice u-momentum southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_southVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_southVarId,'field',                          &
          'uice_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'uice_north',nf90_float,                          &
         (/dim_xi_u,  dim_time/),Uice_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_northVarId,'long_name',                      &
         '2D ice u-momentum northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_northVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_northVarId,'field',                          &
          'uice_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Uice_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'vice_west',nf90_float,                           &
         (/dim_eta_v, dim_time/),Vice_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_westVarId,'long_name',                      &
         '2D ice v-momentum western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_westVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_westVarId,'field',                          &
          'vice_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'vice_east',nf90_float,                           &
         (/dim_eta_v, dim_time/),Vice_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_eastVarId,'long_name',                      &
         '2D ice v-momentum eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_eastVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_eastVarId,'field',                          &
          'vice_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'vice_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Vice_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_southVarId,'long_name',                      &
         '2D ice v-momentum southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_southVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_southVarId,'field',                          &
          'vice_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'vice_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Vice_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_northVarId,'long_name',                      &
         '2D ice v-momentum northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_northVarId,'units','meter second-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_northVarId,'field',                          &
          'vice_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Vice_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'snow_thick_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Hsno_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_westVarId,'long_name',                      &
         'snow thickness western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_westVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_westVarId,'field',                          &
          'snow_thick_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'snow_thick_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Hsno_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_eastVarId,'long_name',                      &
         'snow thickness eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_eastVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_eastVarId,'field',                          &
          'snow_thick_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'snow_thick_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Hsno_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_southVarId,'long_name',                      &
         'snow thickness southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_southVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_southVarId,'field',                          &
          'snow_thick_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'snow_thick_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Hsno_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_northVarId,'long_name',                      &
         'snow thickness northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_northVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_northVarId,'field',                          &
          'snow_thick_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Hsno_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'ti_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Tice_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_westVarId,'long_name',                      &
         'internal ice temperature western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_westVarId,'units','degree Celsius')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_westVarId,'field',                          &
          'ti_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ti_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Tice_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_eastVarId,'long_name',                      &
         'internal ice temperature eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_eastVarId,'units','degree Celsius')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_eastVarId,'field',                          &
          'ti_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ti_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Tice_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_southVarId,'long_name',                      &
         'internal ice temperature southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_southVarId,'units','degree Celsius')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_southVarId,'field',                          &
          'ti_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ti_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Tice_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_northVarId,'long_name',                      &
         'internal ice temperature northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_northVarId,'units','degree Celsius')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_northVarId,'field',                          &
          'ti_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Tice_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'sfwat_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Sfwat_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_westVarId,'long_name',                      &
         'surface melt pond thickness western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_westVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_westVarId,'field',                          &
          'sfwat_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sfwat_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Sfwat_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_eastVarId,'long_name',                      &
         'surface melt pond thickness eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_eastVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_eastVarId,'field',                          &
          'sfwat_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sfwat_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Sfwat_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_southVarId,'long_name',                      &
         'surface melt pond thickness southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_southVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_southVarId,'field',                          &
          'sfwat_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sfwat_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Sfwat_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_northVarId,'long_name',                      &
         'surface melt pond thickness northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_northVarId,'units','meter')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_northVarId,'field',                          &
          'sfwat_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sfwat_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'ageice_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Ageice_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_westVarId,'long_name',                      &
         'age of ice western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_westVarId,'units','days')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_westVarId,'field',                          &
          'ageice_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ageice_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Ageice_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_eastVarId,'long_name',                      &
         'age of ice eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_eastVarId,'units','days')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_eastVarId,'field',                          &
          'ageice_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ageice_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Ageice_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_southVarId,'long_name',                      &
         'age of ice southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_southVarId,'units','days')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_southVarId,'field',                          &
          'ageice_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'ageice_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Ageice_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_northVarId,'long_name',                      &
         'age of ice northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_northVarId,'units','days')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_northVarId,'field',                          &
          'ageice_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Ageice_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig11_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Sig11_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_westVarId,'long_name',                      &
         'internal ice stress component 11 western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_westVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_westVarId,'field',                          &
          'sig11_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig11_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Sig11_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_eastVarId,'long_name',                      &
         'internal ice stress component 11 eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_eastVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_eastVarId,'field',                          &
          'sig11_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig11_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Sig11_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_southVarId,'long_name',                      &
         'internal ice stress component 11 southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_southVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_southVarId,'field',                          &
          'sig11_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig11_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Sig11_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_northVarId,'long_name',                      &
         'internal ice stress component 11 northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_northVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_northVarId,'field',                          &
          'sig11_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig11_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig22_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Sig22_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_westVarId,'long_name',                      &
         'internal ice stress component 22 western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_westVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_westVarId,'field',                          &
          'sig22_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig22_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Sig22_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_eastVarId,'long_name',                      &
         'internal ice stress component 22 eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_eastVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_eastVarId,'field',                          &
          'sig22_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig22_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Sig22_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_southVarId,'long_name',                      &
         'internal ice stress component 22 southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_southVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_southVarId,'field',                          &
          'sig22_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig22_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Sig22_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_northVarId,'long_name',                      &
         'internal ice stress component 22 northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_northVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_northVarId,'field',                          &
          'sig22_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig22_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)


status = nf90_def_var(nc,'sig12_west',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Sig12_westVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_westVarId,'long_name',                      &
         'internal ice stress component 12 western boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_westVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_westVarId,'field',                          &
          'sig12_west, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_westVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig12_east',nf90_float,                           &
         (/dim_eta_rho, dim_time/),Sig12_eastVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_eastVarId,'long_name',                      &
         'internal ice stress component 12 eastern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_eastVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_eastVarId,'field',                          &
          'sig12_east, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_eastVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig12_south',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Sig12_southVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_southVarId,'long_name',                      &
         'internal ice stress component 12 southern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_southVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_southVarId,'field',                          &
          'sig12_south, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_southVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_def_var(nc,'sig12_north',nf90_float,                          &
         (/dim_xi_rho,  dim_time/),Sig12_northVarId)
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_northVarId,'long_name',                      &
         'internal ice stress component 12 northern boundary condition')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_northVarId,'units','N meter-1')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_northVarId,'field',                          &
          'sig12_north, scalar, series')
if(status /= nf90_NoErr) call handle_err(status)
status = nf90_put_att(nc,Sig12_northVarId,'time','bry_time')
if(status /= nf90_NoErr) call handle_err(status)
!#endif
!                                                                               
! Exit definition mode                                                          
!                                                                               
status = nf90_enddef(nc)
if(status /= nf90_NoErr) call handle_err(status)
!
write(*,*) 'Finished file definition'
!
!
! -------------------------------------------------------------------
!
! Read in climatology arrays and output boundary arrays for each variable
!
! Loop through time steps
!
DO itime = 1,ztime
   status = nf90_get_var(nc_clim,ZetaVarId,zeta,                             &
                start=(/ 1, 1, itime/))
   zeta_west(:) = zeta(1,:)
   zeta_east(:) = zeta(Lp,:)
   zeta_south(:) = zeta(:,1)
   zeta_north(:) = zeta(:,Mp)
   status = nf90_put_var(nc,Zeta_westVarId,zeta_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Zeta_eastVarId,zeta_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Zeta_southVarId,zeta_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Zeta_northVarId,zeta_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)

ENDDO


DO itime = 1,ntime

   status = nf90_get_var(nc_clim,Clim_timeVarId,time,                        &
                start=(/itime/))
   status = nf90_put_var(nc,Bry_timeVarId,time,(/itime/))
   if(status /= nf90_NoErr) call handle_err(status)


   status = nf90_get_var(nc_clim,SaltVarId,salt,                             &
                start=(/ 1, 1, 1, itime/))
   salt_west(:,:) = salt(1,:,:)
   salt_east(:,:) = salt(Lp,:,:)
   salt_south(:,:) = salt(:,1,:)
   salt_north(:,:) = salt(:,Mp,:)
   status = nf90_put_var(nc,Salt_westVarId,salt_west,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Salt_eastVarId,salt_east,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Salt_southVarId,salt_south,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Salt_northVarId,salt_north,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)

   status = nf90_get_var(nc_clim,TempVarId,temp,                             &
                start=(/ 1, 1, 1, itime/))
   temp_west(:,:) = temp(1,:,:)
   temp_east(:,:) = temp(Lp,:,:)
   temp_south(:,:) = temp(:,1,:)
   temp_north(:,:) = temp(:,Mp,:)
   status = nf90_put_var(nc,Temp_westVarId,temp_west,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Temp_eastVarId,temp_east,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Temp_southVarId,temp_south,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Temp_northVarId,temp_north,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)

   status = nf90_get_var(nc_clim,UVarId,u,                             &
                start=(/ 1, 1, 1, itime/))
   u_west(:,:) = u(1,:,:)
   u_east(:,:) = u(L,:,:)
   u_south(:,:) = u(:,1,:)
   u_north(:,:) = u(:,Mp,:)
   status = nf90_put_var(nc,U_westVarId,u_west,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,U_eastVarId,u_east,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,U_southVarId,u_south,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,U_northVarId,u_north,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)

   status = nf90_get_var(nc_clim,VVarId,v,                             &
                start=(/ 1, 1, 1, itime/))
   v_west(:,:) = v(1,:,:)
   v_east(:,:) = v(Lp,:,:)
   v_south(:,:) = v(:,1,:)
   v_north(:,:) = v(:,M,:)
   status = nf90_put_var(nc,V_westVarId,v_west,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,V_eastVarId,v_east,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,V_southVarId,v_south,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,V_northVarId,v_north,(/1,1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)


   status = nf90_get_var(nc_clim,UbarVarId,ubar,                             &
                start=(/ 1, 1, itime/))
   ubar_west(:) = ubar(1,:)
   ubar_east(:) = ubar(L,:)
   ubar_south(:) = ubar(:,1)
   ubar_north(:) = ubar(:,Mp)
   status = nf90_put_var(nc,Ubar_westVarId,ubar_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Ubar_eastVarId,ubar_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Ubar_southVarId,ubar_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Ubar_northVarId,ubar_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)

   status = nf90_get_var(nc_clim,VbarVarId,vbar,                             &
                start=(/ 1, 1, itime/))
   vbar_west(:) = vbar(1,:)
   vbar_east(:) = vbar(Lp,:)
   vbar_south(:) = vbar(:,1)
   vbar_north(:) = vbar(:,M)
   status = nf90_put_var(nc,Vbar_westVarId,vbar_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Vbar_eastVarId,vbar_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Vbar_southVarId,vbar_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Vbar_northVarId,vbar_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! !#ifdef ICE_OUT
! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,AiceVarId,aice,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     aice_west(:) = aice(1,:)
     aice_east(:) = aice(Lp,:)
     aice_south(:) = aice(:,1)
     aice_north(:) = aice(:,Mp)
   else
     aice_west(:) = 0.
     aice_east(:) = 0.
     aice_south(:) = 0.
     aice_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,HiceVarId,hice,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     hice_west(:) = hice(1,:)
     hice_east(:) = hice(Lp,:)
     hice_south(:) = hice(:,1)
     hice_north(:) = hice(:,Mp)
   else
     hice_west(:) = 0.
     hice_east(:) = 0.
     hice_south(:) = 0.
     hice_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,HsnoVarId,hsno,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     hsno_west(:) = hsno(1,:)
     hsno_east(:) = hsno(Lp,:)
     hsno_south(:) = hsno(:,1)
     hsno_north(:) = hsno(:,Mp)
   else 
     hsno_west(:) = 0.
     hsno_east(:) = 0.
     hsno_south(:) = 0.
     hsno_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,UiceVarId,uice,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     uice_west(:) = uice(1,:)
     uice_east(:) = uice(L,:)
     uice_south(:) = uice(:,1)
     uice_north(:) = uice(:,Mp)
   else
     uice_west(:) = 0.
     uice_east(:) = 0.
     uice_south(:) = 0.
     uice_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,ViceVarId,zeta,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     vice_west(:) = vice(1,:)
     vice_east(:) = vice(Lp,:)
     vice_south(:) = vice(:,1)
     vice_north(:) = vice(:,M)
   else
     vice_west(:) = 0.
     vice_east(:) = 0.
     vice_south(:) = 0.
     vice_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,TiceVarId,tice,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     tice_west(:) = tice(1,:)
     tice_east(:) = tice(Lp,:)
     tice_south(:) = tice(:,1)
     tice_north(:) = tice(:,Mp)
   else
     tice_west(:) = -2.
     tice_east(:) = -2.
     tice_south(:) = -2.
     tice_north(:) = -2.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,SfwatVarId,sfwat,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     sfwat_west(:) = sfwat(1,:)
     sfwat_east(:) = sfwat(Lp,:)
     sfwat_south(:) = sfwat(:,1)
     sfwat_north(:) = sfwat(:,Mp)
   else
     sfwat_west(:) = 0.
     sfwat_east(:) = 0.
     sfwat_south(:) = 0.
     sfwat_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,AgeiceVarId,ageice,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     ageice_west(:) = ageice(1,:)
     ageice_east(:) = ageice(Lp,:)
     ageice_south(:) = ageice(:,1)
     ageice_north(:) = ageice(:,Mp)
   else
     ageice_west(:) = 0.
     ageice_east(:) = 0.
     ageice_south(:) = 0.
     ageice_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,Sig11VarId,sig11,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     sig11_west(:) = sig11(1,:)
     sig11_east(:) = sig11(Lp,:)
     sig11_south(:) = sig11(:,1)
     sig11_north(:) = sig11(:,Mp)
   else
     sig11_west(:) = 0.
     sig11_east(:) = 0.
     sig11_south(:) = 0.
     sig11_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,Sig22VarId,sig22,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     sig22_west(:) = sig22(1,:)
     sig22_east(:) = sig22(Lp,:)
     sig22_south(:) = sig22(:,1)
     sig22_north(:) = sig22(:,Mp)
   else 
     sig22_west(:) = 0.
     sig22_east(:) = 0.
     sig22_south(:) = 0.
     sig22_north(:) = 0.
   end if

! !# ifdef ICE_IN
   status = nf90_get_var(nc_clim,Sig12VarId,sig12,                             &
                start=(/ 1, 1, itime/))
   if(status == nf90_NoErr) then
     sig12_west(:) = sig12(1,:)
     sig12_east(:) = sig12(Lp,:)
     sig12_south(:) = sig12(:,1)
     sig12_north(:) = sig12(:,Mp)
   else
     sig12_west(:) = 0.
     sig12_east(:) = 0.
     sig12_south(:) = 0.
     sig12_north(:) = 0.
   end if


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   status = nf90_put_var(nc,Aice_westVarId,aice_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Aice_eastVarId,aice_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Aice_southVarId,aice_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Aice_northVarId,aice_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Hice_westVarId,hice_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Hice_eastVarId,hice_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Hice_southVarId,hice_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Hice_northVarId,hice_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Hsno_westVarId,hsno_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Hsno_eastVarId,hsno_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Hsno_southVarId,hsno_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Hsno_northVarId,hsno_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Uice_westVarId,uice_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Uice_eastVarId,uice_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Uice_southVarId,uice_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Uice_northVarId,uice_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Vice_westVarId,vice_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Vice_eastVarId,vice_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Vice_southVarId,vice_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Vice_northVarId,vice_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Tice_westVarId,tice_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Tice_eastVarId,tice_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Tice_southVarId,tice_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Tice_northVarId,tice_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sfwat_westVarId,sfwat_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sfwat_eastVarId,sfwat_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sfwat_southVarId,sfwat_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sfwat_northVarId,sfwat_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Ageice_westVarId,ageice_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Ageice_eastVarId,ageice_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Ageice_southVarId,ageice_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Ageice_northVarId,ageice_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig11_westVarId,sig11_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig11_eastVarId,sig11_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig11_southVarId,sig11_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig11_northVarId,sig11_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig22_westVarId,sig22_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig22_eastVarId,sig22_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig22_southVarId,sig22_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig22_northVarId,sig22_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig12_westVarId,sig12_west,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig12_eastVarId,sig12_east,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig12_southVarId,sig12_south,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
   status = nf90_put_var(nc,Sig12_northVarId,sig12_north,(/1,itime/))
   if(status /= nf90_NoErr) call handle_err(status)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!#endif
   write(*,*) 'Fields at record ',itime,', time = ',time,' days written'

ENDDO

status = nf90_close(nc_clim)
if(status /= nf90_NoErr) call handle_err(status)

status = nf90_close(nc)
if(status /= nf90_NoErr) call handle_err(status)

END PROGRAM bry_from_clim

