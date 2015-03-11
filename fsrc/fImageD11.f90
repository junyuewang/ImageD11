

subroutine assign( ubi, gv, tol, drlv2, labels, ig, n)
    implicit none
    real(8), intent(in) :: ubi(3,3), gv(3,n), tol
    integer, intent(in) :: n, ig
    integer, intent(inout) :: labels(n)
    real(8), intent(inout) :: drlv2(n)
    real(8) :: dr, h(3), ttol, dh(3)
    integer :: i
    ttol = tol*tol
!$omp parallel do private(h,dr,dh)
    do i=1,n
       h(1)=ubi(1,1)*gv(1,i) + ubi(1,2)*gv(2,i) + ubi(1,3)*gv(3,i) 
       h(2)=ubi(2,1)*gv(1,i) + ubi(2,2)*gv(2,i) + ubi(2,3)*gv(3,i) 
       h(3)=ubi(3,1)*gv(1,i) + ubi(3,2)*gv(2,i) + ubi(3,3)*gv(3,i) 
       dh = floor(h+0.5) - h
       dr =  dh(1)*dh(1) + dh(2)*dh(2) + dh(3)*dh(3)
       if ( (dr.lt.ttol) .and. (dr.lt.drlv2(i)) ) then
          drlv2(i) = dr
          labels(i) = ig
       else if (labels(i).eq.ig) then
          labels(i) = -1
       endif
    enddo
end subroutine assign


! compute_gv for refinegrains.py

subroutine compute_gv( xlylzl, omega, omegasign, wvln, wedge, chi, t, gv, n )
  use omp_lib
  implicit none
  real, intent(in) :: xlylzl(3,n), omega(n), wvln, wedge, chi, t(3)
  real(8), intent(inout):: gv(3,n)
  integer, intent(in) ::  n, omegasign
  real :: sc,cc,sw,cw,wmat(3,3),cmat(3,3), mat(3,3), u(3),d(3),v(3)
  real :: modyz, o(3), co, so, ds, k(3)
  real, parameter :: PI=3.141592653589793,RAD=PI/180.0,DEG=180.0/PI
  integer :: i

  ! Fill in rotation matrix of wedge, chi
  sw = sin(wedge*RAD)
  cw = cos(wedge*RAD)
  sc = sin(chi*RAD)
  cc = cos(chi*RAD)
  wmat = RESHAPE ((/ cw,0.,-sw,0.,1.,0.,sw,0.,cw /), (/3,3/))
  cmat = RESHAPE ((/ 1.,0.,0.,0.,cc,sc,0.,-sc,cc /), (/3,3/))
  mat = matmul(cmat, wmat)
!  write(*,*)'threads',omp_get_max_threads()
!  write(*,*)'mat',mat
!$omp parallel do private(so,co,u,o,d,modyz,ds,v,k)
  do i=1,n
     ! Compute translation + rotation for grain origin
     so = sin(RAD*omega(i)*omegasign)
     co = cos(RAD*omega(i)*omegasign)
     u(1) =  co*t(1) - so*t(2)
     u(2) =  so*t(1) + co*t(2)
     u(3) = t(3)
     ! grain origin, difference vec, |yz| component
     ! o = matmul(transpose(mat),u)
     o(1) = mat(1,1)*u(1)+mat(2,1)*u(2)+mat(3,1)*u(3)
     o(2) = mat(1,2)*u(1)+mat(2,2)*u(2)+mat(3,2)*u(3)
     o(3) = mat(1,3)*u(1)+mat(2,3)*u(2)+mat(3,3)*u(3)
     d = xlylzl(:,i) - o
     modyz  = 1./sqrt(d(1)*d(1) + d(2)*d(2) + d(3)*d(3))
     ! k-vector
     ds = 1./wvln
     k(1) = ds*(d(1)*modyz - 1. )
     k(2) = ds*d(2)*modyz
     k(3) = ds*d(3)*modyz
     v = matmul(mat,k)
     gv(1,i)= co*v(1) + so*v(2)
     gv(2,i)=-so*v(1) + co*v(2)
     gv(3,i)=v(3)
  enddo
 
end subroutine compute_gv


! set LDFLAGS="-static-libgfortran -static-libgcc -static -lgomp -shared"  
! f2py -m fImageD11 -c fImageD11.f90 --opt=-O3 --f90flags="-fopenmp" -lgomp -lpthread
! export OMP_NUM_THREADS=12
! python tst.py ../test/nac_demo/peaks.out_merge_t200 ../test/nac_demo/nac.prm 

! f2py -m fImageD11 -c fImageD11.f90 --f90flags="-fopenmp" -lgomp -lpthread  --fcompiler=gnu95 --compiler=mingw32
