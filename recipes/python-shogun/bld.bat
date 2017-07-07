setlocal EnableDelayedExpansion

mkdir build
cd build

FOR /F "tokens=* USEBACKQ" %%F IN (`%PYTHON% -c "from distutils import sysconfig; print(sysconfig.get_python_inc())"`) DO (
SET PY_INCLUDE=%%F
)

REM TODO: this won't work e.g. if the version is 3.6m
REM Not sure how to do the ldd / otool type analysis on Windows
REM Best solution will be https://github.com/conda/conda-build/issues/2130
SET PYLIB="%LIBRARY_PREFIX/libpython%PY_VER%.dll"

%LIBRARY_BIN%\cmake .. ^
    -G"%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH="%PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_META_EXAMPLES=OFF ^
    -DENABLE_TESTING=OFF ^
    -DENABLE_COVERAGE=OFF ^
    -DLIBSHOGUN=OFF ^
    -DSWIG_EXECUTABLE="%LIBRARY_BIN%\swig" ^
    -DPYTHON_INCLUDE_DIR="%PY_INCLUDE%" ^
    -DPYTHON_LIBRARY="%PYLIB%" ^
    -DPYTHON_EXECUTABLE="%PYTHON%" ^
    -DPythonModular=ON
if errorlevel 1 exit 1

msbuild shogun.sln
if errorlevel 1 exit 1
