program meanzeta
! nilsmk@met.no 17/10/2012

use netcdf

implicit none
REAL, DIMENSION(:,:,:), ALLOCATABLE :: zeta
REAL, DIMENSION(:,:), ALLOCATABLE :: zetamean
character(len=99) :: infile,mZetaFile
character(len=80) :: x_dimname,y_dimname,time_dimname
integer   :: X,Xz,Y,Yz,TIME,ncid,ncid2,dim_x,dim_y,dim_time,k,i,j
integer   :: statusi,statuso,zetaVarId,zetaVarId2

call getarg(1,infile)
call getarg(2,mZetaFile)

X = 0
Y = 0

statusi = nf90_open(trim(infile),nf90_write,ncid)
statusi = nf90_inq_dimid(ncid,'X',dim_x)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid,'rlon',dim_x)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid,'xi_rho',dim_x)
statusi = nf90_inq_dimid(ncid,'Y',dim_y)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid,'rlat',dim_y)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid,'eta_rho',dim_y)
statusi = nf90_Inquire_Dimension(ncid,dim_x,x_dimname,X)
statusi = nf90_Inquire_Dimension(ncid,dim_y,y_dimname,Y)
statusi = nf90_inq_dimid(ncid,'time',dim_time)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid,'ocean_time',dim_time)
statusi = nf90_Inquire_Dimension(ncid,dim_time,time_dimname,TIME)

write(*,*) 'infile= ',infile
write(*,*) 'X, Y, TIME = ',X,Y,TIME
allocate(zeta(X,Y,TIME))
statusi = nf90_inq_varid(ncid,'zeta_detided',zetaVarId)
statusi = nf90_get_var(ncid,zetaVarId,zeta)

statusi = nf90_open(trim(mZetaFile),nf90_write,ncid2)
statusi = nf90_inq_dimid(ncid2,'X',dim_x)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid2,'rlon',dim_x)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid2,'xi_rho',dim_x)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid2,'x',dim_x)
statusi = nf90_inq_dimid(ncid2,'Y',dim_y)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid2,'rlat',dim_y)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid2,'eta_rho',dim_y)
if (statusi /= nf90_noerr) statusi = nf90_inq_dimid(ncid2,'y',dim_y)
statusi = nf90_Inquire_Dimension(ncid2,dim_x,x_dimname,Xz)
statusi = nf90_Inquire_Dimension(ncid2,dim_y,y_dimname,Yz)

write(*,*) 'file containing mean zeta= ',mZetaFile
write(*,*) 'X, Y = ',Xz,Yz
allocate(zetamean(Xz,Yz))
statusi = nf90_inq_varid(ncid2,'zeta',zetaVarId2)
statusi = nf90_get_var(ncid2,zetaVarId2,zetamean)





do k=1,TIME
   if (Xz < X) zeta(2:(X-1),2:(Y-1),k)=zeta(2:(X-1),2:(Y-1),k)-zetamean(:,:)
   if (Xz == X) zeta(:,:,k)=zeta(:,:,k)-zetamean(:,:)
end do

where (zeta > 1000.) zeta=1e+37

statuso = nf90_put_var(ncid,zetaVarId,zeta)
statuso = nf90_close(ncid)



end program meanzeta
