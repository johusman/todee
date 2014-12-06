#!/bin/sh

version=$(date +%Y%m%d)
release="todee$version"

head -n  $(( $(wc -l about.txt | awk '{print $1}') - 1 )) about.txt > /tmp/about.txt
cp /tmp/about.txt about.txt
echo "This is version $version" >> about.txt

if [ ! -e nodist/releases ]; then
	mkdir nodist/releases
fi

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
