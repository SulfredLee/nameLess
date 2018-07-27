#!/bin/bash
ThisScript=$0
InputPath=$1
OutputPath=$2

if [ "$InputPath" == "" ]; then
    InputPath=$PWD
    echo "Input Path is $InputPath"
fi
if [ "$OutputPath" == "" ]; then
    OutputPath=$PWD
    echo "Output Path is $OutputPath"
fi

find $InputPath -type f -name "*.h" -o -name "*.hpp" | sed -r 's|/[^/]+$||' | sort | uniq | awk '{printf "-I%s\n", $1}' > $OutputPath/.clang_complete
echo "-I/usr/local/boost/1.59.0/include" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/Qt3DCore" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/Qt3DInput" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/Qt3DLogic" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/Qt3DQuick" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/Qt3DQuickInput" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/Qt3DQuickRender" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/Qt3DRender" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtBluetooth" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtCLucene" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtConcurrent" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtCore" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtDBus" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtDesigner" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtDesignerComponents" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtGui" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtHelp" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtLabsControls" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtLabsTemplates" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtLocation" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtMultimedia" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtMultimediaQuick_p" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtMultimediaWidgets" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtNetwork" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtNfc" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtOpenGL" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtOpenGLExtensions" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtPlatformHeaders" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtPlatformSupport" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtPositioning" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtPrintSupport" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtQml" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtQmlDevTools" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtQuick" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtQuickParticles" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtQuickTest" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtQuickWidgets" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtScript" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtScriptTools" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtSensors" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtSerialBus" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtSerialPort" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtSql" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtSvg" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtTest" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtUiPlugin" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtUiTools" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtWebChannel" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtWebEngine" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtWebEngineCore" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtWebEngineWidgets" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtWebSockets" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtWebView" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtWidgets" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtX11Extras" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtXml" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/QtXmlPatterns" >> $OutputPath/.clang_complete
echo "-I/usr/local/Qt/5.6.2/5.6/gcc_64/include/tags" >> $OutputPath/.clang_complete
