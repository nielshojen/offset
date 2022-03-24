USE_PKGBUILD=1
include /usr/local/share/luggage/luggage.make
PB_EXTRA_ARGS+= --sign "[name of your installer dev cert]"
TITLE=offset
REVERSE_DOMAIN=com.github
PACKAGE_VERSION=2.0.1
PYTHONTOOLDIR=/tmp/relocatable-python-git
DEV_APP_CERT=[name of your app dev cert]

-include config.mk

PAYLOAD=\
	pack-script \
	pack-Library-LaunchAgents-com.github.offset.logout.plist \
	pack-script-preinstall \
	pack-python \
	sign

pack-script: l_usr_local
	@sudo mkdir -p ${WORK_D}/usr/local/offset/share
	@sudo mkdir -p ${WORK_D}/usr/local/offset/logout-every
	@sudo ${CP} offset ${WORK_D}/usr/local/offset/
	@sudo ${CP} preferences.plist ${WORK_D}/usr/local/offset/share
	@sudo chown -R root:wheel ${WORK_D}/usr/local/offset/

pack-python: clean-python build-python
	@sudo ${CP} -R Python.framework ${WORK_D}/usr/local/offset/
	@sudo chown -R root:wheel ${WORK_D}/usr/local/offset/
	@sudo chmod -R 755 ${WORK_D}/usr/local/offset/
	@sudo ln -s Python.framework/Versions/Current/bin/python3 ${WORK_D}/usr/local/offset/offset-python
	@sudo ${RM} -rf Python.framework

clean-python:
	@sudo ${RM} -rf Python.framework
	@sudo ${RM} -f ${WORK_D}/usr/local/offset/offset-python
	@sudo ${RM} -rf ${WORK_D}/usr/local/offset/Python.framework

build-python:
	@rm -rf "${PYTHONTOOLDIR}"
	@git clone https://github.com/gregneagle/relocatable-python.git "${PYTHONTOOLDIR}"
	@./build_python_framework.sh
	@find ./Python.framework -name '*.pyc' -delete

sign:
	@sudo /usr/bin/codesign -s "${DEV_APP_CERT}" -i ${REVERSE_DOMAIN}.${TITLE} ${WORK_D}/usr/local/offset/offset
	@sudo ./sign_python_framework.py -v -S "${DEV_APP_CERT}" -L ${WORK_D}/usr/local/offset/Python.framework