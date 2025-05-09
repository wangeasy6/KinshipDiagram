#ifndef CONFIG_H
#define CONFIG_H

#include <QObject>
#include <QFile>
#include <QJsonObject>
#include <QList>
#include <QTranslator>
#include "FileUtils.h"

class Config : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QList<QString> historyList MEMBER m_historyList NOTIFY sigHistoryListChanged)
    Q_PROPERTY(QString dbPrefix READ dbPrefix CONSTANT)
    Q_PROPERTY(QString language READ Language WRITE setLanguage NOTIFY sigLanguageChanged)

public:
    Config();
    Q_INVOKABLE bool updatePath(const QString path);
    Q_INVOKABLE QString dbPath() const {return m_dbPath;};
    Q_INVOKABLE QString dbPrefix() const {return m_dbPrefix;};
    QString Language() const {return m_language;};
    void setLanguage(QString _language);

signals:
    void sigHistoryListChanged();
    void sigLanguageChanged();

private:
    bool writeJsonBack();
    QString m_configPath = "def_cfg.json";
    QList<QString> m_historyList;
    QString m_dbPath;
    QString m_dbPrefix;
    QString m_language = "zh-CN";
    FileUtils m_fileUtils;
    QTranslator m_translator;
    bool initTranslator(QString _language);
    bool setTranslator(QString _language);
};

#endif // CONFIG_H
