AC_DEFUN([DOVECOT_GLIBC], [
  AC_CACHE_CHECK([whether we have glibc],i_cv_have_glibc,[
    AC_EGREP_CPP([we have glibc], [
      #include <features.h>
      #ifdef __GNU_LIBRARY__
        we have glibc
      #endif
    ], [
      i_cv_have_glibc=yes
    ], [
      i_cv_have_glibc=no
    ])
  ])
  AS_IF([test "$i_cv_have_glibc" = "yes"], [
    AC_DEFINE(PREAD_WRAPPERS,, [Define if pread/pwrite needs _XOPEN_SOURCE 500])
  ])
  dnl * Old glibcs have broken posix_fallocate(). Make sure not to use it.
  dnl * It may also be broken in AIX.
  AC_CACHE_CHECK([whether posix_fallocate() works],i_cv_posix_fallocate_works,[
    AC_RUN_IFELSE([AC_LANG_PROGRAM([[
      #define _XOPEN_SOURCE 600
      #include <stdio.h>
      #include <stdlib.h>
      #include <fcntl.h>
      #include <unistd.h>
      #if defined(__GLIBC__) && (__GLIBC__ < 2 || __GLIBC_MINOR__ < 7)
        possibly broken posix_fallocate
      #endif
      ]], [[
        int fd = creat("conftest.temp", 0600);
        int ret;
        if (fd == -1) {
          perror("creat()");
          return 2;
        }
        ret = posix_fallocate(fd, 1024, 1024) < 0 ? 1 : 0;
        unlink("conftest.temp");
        return ret;
    ]])],[
      i_cv_posix_fallocate_works=yes
    ], [
      i_cv_posix_fallocate_works=no
    ],[])
  ])
  AS_IF([test $i_cv_posix_fallocate_works = yes], [
    AC_DEFINE(HAVE_POSIX_FALLOCATE,, [Define if you have a working posix_fallocate()])
  ])
])
