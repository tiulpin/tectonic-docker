# 🐳 Tectonic with Biber 
A tiny docker image with a working [tectonic latex
engine](https://tectonic-typesetting.github.io/en-US/index.html) and [biber](https://github.com/plk/biblatex) with a primed cache + font-awesome for moderncv LaTeX compatibility.


## Getting the image
```
docker pull tiulpin/tectonic-docker
```

Only **~75MB** compressed.

A fully working latex engine. Packages that are not in the cache will be
downloaded on demand.

# Example: Gitlab CI

Create a `.gitlab-ci.yml` with the following content for very fast
pdf builds.

```yaml
pdf:
  image: tiulpin/tectonic-docker
  script:
    - tectonic --keep-intermediates --reruns 0 main.tex
    - biber main
    - tectonic main.tex
  artifacts:
    paths:
      - main.pdf
```

## Example: Gitlab CI (without biber)
In case you dont need biber, you simply ommit the first two script calls. Eg.

```yaml
pdf:
  image: tiulpin/tectonic-docker
  script:
    - tectonic main.tex
  artifacts:
    paths:
      - main.pdf
```

# Example: Travis CI
Create a `.travis.yml` file with, assuming the main tex file to be `main.tex`.
If your `main.tex` file is in a subfolder (for example src/main.tex), adjust the second line to src=$TRAVIS_BUILD_DIR/mysubfolder (eg src=$TRAVIS_BUILD_DIR/src)

```yaml
sudo: required

services:
  - docker

script:
 - docker run --mount src=$TRAVIS_BUILD_DIR,target=/usr/src/tex,type=bind tiulpin/tectonic-docker
  /bin/sh -c "tectonic --keep-intermediates --reruns 0 main.tex; biber main; tectonic main.tex"
```

## Example: Travis CI (without biber)
In case you dont need biber, you simply use this config with a slightly adjusted docker run:
```yaml
sudo: required

services:
  - docker

script:
 - docker run --mount src=$TRAVIS_BUILD_DIR,target=/usr/src/tex,type=bind tiulpin/tectonic-docker
  /bin/sh -c "tectonic main.tex"
```

### Priming the cache

After building tectonic, it is run on the tex files in this repo to
download all the common files from the tectonic bundle. These files are bundled in the docker image

## Running locally

`docker run -it -v /home/user/mytex/folder/thesis:/data tiulpin/tectonic-docker`

Afterwards you can cd into /data and run tectonic/biber as you wish.
Eg:
```
cd /data
tectonic --keep-intermediates --reruns 0 main.tex
biber main
tectonic main.tex
```

