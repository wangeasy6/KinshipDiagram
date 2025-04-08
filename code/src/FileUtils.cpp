#include "FileUtils.h"
#include <QFile>
#include <QDir>
#include <QDebug>
#include <QMetaObject>
#include <QMetaProperty>
#include <QTransform>


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

// void FileUtils::loadFile(const QString& filePath)
// {
//     QFile file(filePath);
//     if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
//         emit errorOccurred("Missing file: " + filePath);
//         return;
//     }

//     QTextStream in(&file);
//     QString content = in.readAll();
//     file.close();

//     emit fileLoaded(content);
// }

bool FileUtils::loadFile(const QString& filePath, QObject* textObject)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString errorMsg = "Missing file: " + filePath;
        if (textObject) {
            textObject->setProperty("text", errorMsg);
        }
        return false;
    }

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    if (textObject) {
        textObject->setProperty("text", content);
    }

    return true;
}


QImage FileUtils::rotateAndCrop(const QImage& original, qreal angle, QRect& cropRect)
{
    QTransform transform;
    transform.rotate(angle);
    QImage rotated = original.transformed(transform, Qt::FastTransformation);

    // Convert to coordinates relative to the upper left corner
    int left = cropRect.x() + rotated.width() / 2;
    int top = cropRect.y() + rotated.height() / 2;

    return rotated.copy(left, top, cropRect.width(), cropRect.height());
}


bool FileUtils::saveClipImg(QString source, QString savePath, QRect rect, int rotation)
{
    if (source.startsWith("file:///")) {
        source.remove(0, 8);
    }
    if (savePath.startsWith("file:///")) {
        savePath.remove(0, 8);
    }

    QImage image(source);
    if (image.isNull()) {
        qDebug() << "Image open failed: " << source;
        return false;
    }

    QImage result = rotateAndCrop(image, rotation, rect);
    if (result.isNull())
        return false;

    result.save(savePath);
    return true;
}
