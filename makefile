SHELL := /bin/zsh
ANDROID = PATH:/Users/shawnbalcome/Library/Android/sdk/build-tools/24.0.1
LOVE_NAME = snake_life.love
BUILD_DIR = .
OUTPUT_DIR = ${BUILD_DIR}/output
NAME = test
APK_NAME = ${NAME}.apk
PACKAGE_NAME = com.${NAME}.flamendless
TEST_APK_NAME = ${NAME}-unaligned.apk
KS_FILE = ${BUILD_DIR}/file.keystore
PASSWORD = secret

test:
	echo "Testing"
	love .

build-android: build-love apk-compile apk-sign apk-install

build-love:
	echo "making .love file..."
	noglob zip -9rv ${OUTPUT_DIR}/${LOVE_NAME} . -x *.git* *.md* *.txt* *.rst* *docs/* *.ase* *.swp* *spec/* *test/* *rockspec* *.mak* *.yml* *ctags* *Makefile* *build/*;
	echo "made .love file!"

apk-compile:
	echo "copying .love to build"
	cp ${OUTPUT_DIR}/${LOVE_NAME} ${BUILD_DIR}/decoded/assets/
	echo "copied!"
	echo "compiling apk..."
	apktool b -o ${OUTPUT_DIR}/${APK_NAME} ${BUILD_DIR}/decoded;
	echo "compiled apk!"

apk-sign:
	echo "signing apk..."
	apk-signer -f ${OUTPUT_DIR}/${APK_NAME} -a flamendless -k ${KS_FILE} -s ${PASSWORD};
	echo "signed apk!"

apk-install:
	echo "adb installing..."
	adb uninstall ${PACKAGE_NAME}
	adb install ${TEST_APK_NAME}
	echo "adb installed"
