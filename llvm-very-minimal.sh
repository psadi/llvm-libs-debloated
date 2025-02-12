#!/bin/sh

set -e

export ARCH="$(uname -m)"

case "${ARCH}" in
"x86_64")
	TARGETS_TO_BUILD="X86;AMDGPU"
	;;
"aarch64")
	TARGETS_TO_BUILD="AArch64;AMDGPU"
	;;
*)
	echo -e "Unsupported Arch: '${ARCH}'"
	exit 1
	;;
esac

git clone https://gitlab.archlinux.org/archlinux/packaging/packages/llvm llvm
cd ./llvm

sed -i -e 's/-g1/-g0/' \
	-e "s/x86_64/${ARCH}/" \
	-e 's|-DCMAKE_BUILD_TYPE=Release|-DCMAKE_BUILD_TYPE=MinSizeRel|' \
	-e 's|-DLLVM_BUILD_TESTS=ON|-DLLVM_BUILD_TESTS=OFF|' \
	-e 's|-DLLVM_ENABLE_CURL=ON|-DLLVM_ENABLE_CURL=OFF|' \
	-e "s|-DLLVM_BUILD_DOCS=ON|-DLLVM_TARGETS_TO_BUILD=\"${TARGETS_TO_BUILD}\"|" \
	-e 's|-DLLVM_ENABLE_SPHINX=ON|-DLLVM_ENABLE_SPHINX=OFF|' \
	-e 's|rm -r|#rm -r|' ./PKGBUILD

cat ./PKGBUILD

makepkg -f --skippgpcheck
ls -la
mv ./llvm-libs-*.pkg.tar.${EXT} ../llvm-libs-minimal.pkg.tar.${EXT}
cd ..
rm -rf ./llvm
echo "All done!"
