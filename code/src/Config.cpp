#include "Config.h"
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>
#include <QFileInfo>
#include <QDir>

Config::Config()
{

    QFile configFd;
    configFd.setFileName(m_configPath);
    if (!configFd.open(QIODevice::ReadWrite | QIODevice::Text)) {
        qDebug() << "Unable to open: " << m_configPath;
        return;
    }

    QString jsonString;

    QTextStream in(&configFd);
    while (!in.atEnd()) {
        jsonString += in.readLine();
    }
    configFd.close();
    // qDebug().noquote() << jsonString;

    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonString.toUtf8());
    if (jsonDoc.isArray()) {
        for (const QJsonValue& value : jsonDoc.array()) {
            if (value.isString() && m_fileUtils.isFileExist(value.toString())) {
                m_historyList.append(value.toString());
            }
        }
    }
}


bool Config::updatePath(const QString path)
{
    // Get prefix
    QFileInfo fileInfo(path);
    m_dbPath = "file:///" + path;
    m_dbPrefix = "file:///" + fileInfo.dir().path() + "/";
    qDebug() << "Current mpa path: " << m_dbPath;
    qDebug() << "Current mpa prefix: " << m_dbPrefix;

    // Update list
    int index = m_historyList.indexOf(path);
    if (index != -1) {
        m_historyList.removeAt(index);
    }
    m_historyList.insert(0, path);

    // Max length clear
    while (m_historyList.length() > 10)
        m_historyList.removeAt(10);

    // Write back
    QJsonArray historyListJson;
    for (const QString& item : m_historyList) {
        historyListJson.append(item);
    }
    QJsonDocument document(historyListJson);

    QFile jsonFd(m_configPath);
    if (!jsonFd.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qDebug() << "Unable to open file: " << m_configPath;
        return false;
    }
    jsonFd.write(document.toJson());
    jsonFd.close();

    return true;
}
