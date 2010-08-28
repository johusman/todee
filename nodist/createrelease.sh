#!/bin/sh

if [ ! -e nodist/releases ]; then
	mkdir nodist/releases
fi

release="todee$(date +%Y%m%d)"

if [ ! -e "nodist/releases/$release" ]; then
	mkdir nodist/releases/$release
fi

for f in * ; do
	if [ $f != "nodist" ]; then
		cp -r $f nodist/releases/$release
	fi
done

cd nodist/releases
zip -r ${release}.zip $release
cd ../..
