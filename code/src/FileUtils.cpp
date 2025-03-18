#include "FileUtils.h"
#include <QFile>
#include <QDir>
#include <QDebug>


FileUtils::FileUtils(QObject* parent)
    : QObject{parent}
{}


bool FileUtils::isFileExist(QString _path)
{
    if (_path.startsWith("file:///")) {
        _path.remove(0, 8);
    }
    return QFile::exists(_path);
}


bool FileUtils::isFolderExist(QString _path)
{
    if (_path.startsWith("file:///")) {
        _path.remove(0, 8);
    }
    return QDir(_path).exists();
}


bool FileUtils::deleteFile(QString _path)
{
    if (_path.startsWith("file:///")) {
        _path.remove(0, 8);
    }

    QFile targetFile(_path);

    if (targetFile.exists()) {
        qDebug() << "deleteFile: " << _path;
        targetFile.remove();
    }

    return true;
}


bool FileUtils::copyFile(QString _from, QString _to)
{
    if (_from.startsWith("file:///")) {
        _from.remove(0, 8);
    }
    if (_to.startsWith("file:///")) {
        _to.remove(0, 8);
    }

    qDebug() << _from << " -> " << _to;

    QFile sourceFile(_from);
    if (!sourceFile.open(QIODevice::ReadOnly)) {
        qDebug() << "Unable open file:" << _from;
        return false;
    }
    sourceFile.close();

    bool result = QFile::copy(_from, _to);
    if (result) {
        qDebug() << "File copied successfully.";
    } else {
        qDebug() << "File copying failed.";
    }

    return result;
}


bool FileUtils::copyFileOverlay(QString _from, QString _to)
{
    if (_from.startsWith("file:///")) {
        _from.remove(0, 8);
    }
    if (_to.startsWith("file:///")) {
        _to.remove(0, 8);
    }

    qDebug() << _from << " -> " << _to;

    QFile sourceFile(_from);
    if (!sourceFile.open(QIODevice::ReadOnly)) {
        qDebug() << "Unable open file:" << _from;
        return false;
    }
    sourceFile.close();

    deleteFile(_to);

    bool result = QFile::copy(_from, _to);
    if (result) {
        qDebug() << "File copied successfully.";
    } else {
        qDebug() << "File copying failed.";
    }

    return result;
}

void FileUtils::loadFile(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit errorOccurred("Unable open: " + filePath);
        return;
    }

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    emit fileLoaded(content);
}
