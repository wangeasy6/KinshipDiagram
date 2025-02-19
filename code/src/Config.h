#ifndef CONFIG_H
#define CONFIG_H

#include <QObject>
#include <QFile>
#include <QJsonObject>
#include <QList>
#include "FileUtils.h"

class Config : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QList<QString> historyList MEMBER m_historyList NOTIFY sigHistoryListChanged)
    Q_PROPERTY(QString dbPrefix READ dbPrefix CONSTANT)

public:
    Config();
    Q_INVOKABLE bool updatePath(const QString path);
    Q_INVOKABLE QString dbPath() const {return m_dbPath;};
    Q_INVOKABLE QString dbPrefix() const {return m_dbPrefix;};

signals:
    void sigHistoryListChanged();

private:
    const QString m_configPath = "def_cfg.json";
    QList<QString> m_historyList;
    QString m_dbPath;
    QString m_dbPrefix;
    FileUtils m_fileUtils;
};

#endif // CONFIG_H
