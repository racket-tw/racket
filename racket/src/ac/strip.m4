if test "${enable_strip}" = "" ; then
  if test "${enable_strip_by_default}" = "yes" ; then
    enable_strip=yes
  fi
fi

try_archive_conftest()
{
   $AR $ARFLAGS conftest.a conftest.$OBJEXT > /dev/null 2>&1
}

ICP_STRIP_FLAG=""

if test "${enable_strip}" = "yes" ; then
  AC_CHECK_TOOL([STRIP], [strip])
  # Used to add -S flag, but not all `strip' variants support it:
  STRIP_DEBUG="${STRIP}"
  if test "${INSTALL_LIBS_ENABLE}" = "install" ; then
    check_strip_dash_s=yes
  fi
  if test "${strip_needs_dash_s}" = "yes" ; then
    check_strip_dash_s=yes
  fi
  if test "${check_strip_dash_s}" = "yes" ; then
    # Can only support library stripping if something like "-S" is available:
    [ msg="for strip -S" ]
    AC_MSG_CHECKING($msg)
    set_strip_lib=no
    AC_COMPILE_IFELSE([AC_LANG_SOURCE([int f() { return 0; }])], try_archive_conftest, set_strip_lib=no )
    if test conftest.a ; then
      if "${STRIP_DEBUG}" -S conftest.a > /dev/null 2>&1 ; then
        STRIP_LIB_DEBUG="${STRIP_DEBUG} -S"
        set_strip_lib=yes
      fi
    fi
    AC_MSG_RESULT($set_strip_lib)
    if test "${strip_needs_dash_s}" = "yes" ; then
      STRIP_DEBUG="${STRIP_LIB_DEBUG}"
    fi
  fi
  ICP_STRIP_FLAG=" -s"
fi

case "$host_os" in
  darwin*)
    if test "${enable_codesign}" = "yes" ; then
      case "$host_cpu" in
         aarch64)
           STRIP_SIGNATURE="codesign --remove-signature"
           RESTORE_SIGNATURE="codesign -s - --entitlements"
         ;;
         *)
          # Check whether `codesign` can remove signatures
          touch sig-test-file
          if `codesign --remove-signature sig-test-file > /dev/null 2>&1` ; then
             STRIP_SIGNATURE="codesign --remove-signature"
          fi
          rm sig-test-file
          ;;
      esac
   else
     STRIP_SIGNATURE='$(STRIP_SIGNATURE_VIA_RACKET)'
     RESTORE_SIGNATURE='$(RESTORE_SIGNATURE_VIA_RACKET)'
   fi
esac
