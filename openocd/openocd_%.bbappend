FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:remove = "file://0001-Makefile.am-Use-SOURCE_DATE_EPOCH-environment-variab.patch"

SRC_URI:append = "\
    file://ti_am64xx_swd_native.cfg \
    file://ti_j784s4_swd_native.cfg \
    file://0001-add-dmem-support-to-am64xx-and-j784s4.patch \
    "

SRCREV_openocd = "66ea461846a3a4a96687c9287c3f61ae8ce0b775"
SRCREV_jimtcl = "f160866171457474f7c4d6ccda70f9b77524407e"
SRCREV_libjaylink = "0d23921a05d5d427332a142d154c213d0c306eb1"

PACKAGECONFIG[dmem] = "--enable-dmem"
PACKAGECONFIG[jimtcl] = "--enable-internal-jimtcl"

PACKAGECONFIG:append = " dmem"
PACKAGECONFIG:append = " jimtcl"

do_configure:prepend() {
    cp ${WORKDIR}/ti_am64xx_swd_native.cfg ${S}/tcl/board/ti_am64xx_swd_native.cfg
    cp ${WORKDIR}/ti_j784s4_swd_native.cfg ${S}/tcl/board/ti_j784s4_swd_native.cfg
}
