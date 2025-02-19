#ifndef FILEUTILS_H
#define FILEUTILS_H

#include <QObject>

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
};

#endif // FILEUTILS_H
