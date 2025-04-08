#ifndef FILEUTILS_H
#define FILEUTILS_H

#include <QObject>
#include <QRect>
#include <QImage>

class FileUtils : public QObject
{
    Q_OBJECT
public:
    explicit FileUtils(QObject* parent = nullptr);
    Q_INVOKABLE bool isFileExist(QString _path);
    Q_INVOKABLE bool isFolderExist(QString _path);
    Q_INVOKABLE bool deleteFile(QString _path);
    Q_INVOKABLE bool copyFile(QString _from, QString _to);
    Q_INVOKABLE bool copyFileOverlay(QString _from, QString _to);
    Q_INVOKABLE bool loadFile(const QString& filePath, QObject* textObject);
    Q_INVOKABLE bool saveClipImg(QString source, QString savePath, QRect rect, int rotation);

private:
    QImage rotateAndCrop(const QImage& original, qreal angle, QRect& cropRect);

};

#endif // FILEUTILS_H
