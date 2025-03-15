#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QString>
#include <QSqlDatabase>
#include <QVariant>

class SettingsManager : public QObject
{
    Q_OBJECT

    // 定义属性，可以在QML中直接绑定
    // 初始化标识
    Q_PROPERTY(bool initialized READ isInitialized WRITE setInitialized NOTIFY initializedChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString photoFormat READ photoFormat WRITE setPhotoFormat NOTIFY photoFormatChanged)
    Q_PROPERTY(QString marriageMode READ marriageMode WRITE setMarriageMode NOTIFY marriageModeChanged)
    Q_PROPERTY(QString photoDisplay READ photoDisplay WRITE setPhotoDisplay NOTIFY photoDisplayChanged)

public:
    explicit SettingsManager(QObject* parent = nullptr);
    SettingsManager(const SettingsManager& other);
    ~SettingsManager();

    // 赋值运算符
    SettingsManager& operator=(const SettingsManager& other);

    // 相等性比较运算符
    bool operator==(const SettingsManager& other) const;
    bool operator!=(const SettingsManager& other) const;

    // 设置数据库连接
    Q_INVOKABLE void setDatabase(const QSqlDatabase& db);

    // 初始化设置表
    Q_INVOKABLE bool initSettingsTable();

    // 从数据库加载所有设置
    Q_INVOKABLE void loadSettings();

    // 获取设置值
    Q_INVOKABLE bool isInitialized() const;
    Q_INVOKABLE QString language() const;
    Q_INVOKABLE QString photoFormat() const;
    Q_INVOKABLE QString marriageMode() const;
    Q_INVOKABLE QString photoDisplay() const;
    Q_INVOKABLE bool isModernMode() const { return m_marriageMode == "modern";};

    // 通用方法获取任意设置
    Q_INVOKABLE QVariant getSetting(const QString& key, const QVariant& defaultValue = QVariant());

public slots:
    // 设置值的方法
    Q_INVOKABLE void setLanguage(const QString& language);
    Q_INVOKABLE void setPhotoFormat(const QString& format);
    Q_INVOKABLE void setMarriageMode(const QString& mode);
    Q_INVOKABLE void setPhotoDisplay(const QString& display);
    Q_INVOKABLE void setInitialized(bool);

    // 通用方法设置任意设置
    Q_INVOKABLE bool setSetting(const QString& key, const QVariant& value);

    // 重置所有设置为默认值
    Q_INVOKABLE bool resetToDefaults();

signals:
    // 属性变化信号
    void initializedChanged();
    void languageChanged();
    void photoFormatChanged();
    void marriageModeChanged();
    void photoDisplayChanged();

    // 通用设置变化信号
    void settingChanged(const QString& key, const QVariant& value);

private:
    QSqlDatabase m_db;
    bool m_initialized = false;

    // 缓存的设置值
    QString m_language;
    QString m_photoFormat;
    QString m_marriageMode;
    QString m_photoDisplay;

    // 更新单个设置到数据库
    bool updateSetting(const QString& key, const QString& value);
};

#endif // SETTINGSMANAGER_H
