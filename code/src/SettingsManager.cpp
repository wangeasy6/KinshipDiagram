#include "SettingsManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QFile>
#include <QDir>

SettingsManager::SettingsManager(QObject* parent)
    : QObject(parent)
    , m_photoFormat(".png")
    , m_marriageMode("modern")
    , m_photoDisplay("with_photo")
{
}

SettingsManager::SettingsManager(const SettingsManager& other)
    : QObject(other.parent())
    , m_photoFormat(other.m_photoFormat)
    , m_marriageMode(other.m_marriageMode)
    , m_photoDisplay(other.m_photoDisplay)
{
}

SettingsManager& SettingsManager::operator=(const SettingsManager& other)
{
    if (this != &other) {
        m_photoFormat = other.m_photoFormat;
        m_marriageMode = other.m_marriageMode;
        m_photoDisplay = other.m_photoDisplay;
    }
    return *this;
}

bool SettingsManager::operator==(const SettingsManager& other) const
{
    return m_photoFormat == other.m_photoFormat &&
           m_marriageMode == other.m_marriageMode &&
           m_photoDisplay == other.m_photoDisplay;
}

bool SettingsManager::operator!=(const SettingsManager& other) const
{
    return !(*this == other);
}

SettingsManager::~SettingsManager()
{
}

void SettingsManager::setDatabase(const QSqlDatabase& db)
{
    m_db = db;
}

bool SettingsManager::initSettingsTable(bool isModernMode)
{
    if (!m_db.isOpen()) {
        qWarning() << "Database not open";
        return false;
    }

    // Create settings table
    QSqlQuery query(m_db);
    if (!query.exec("CREATE TABLE IF NOT EXISTS user_settings ("
                    "setting_key TEXT PRIMARY KEY,"
                    "setting_value TEXT NOT NULL,"
                    "description TEXT"
                    ");")) {
        qWarning() << "Failed to create settings table:" << query.lastError().text();
        return false;
    }

    QString sql = QString(
        "INSERT OR IGNORE INTO user_settings (setting_key, setting_value, description) VALUES "
        "('sql_version', '0.2.0', '数据库定义版本号'), "
        "('photo_format', '.png', '默认裁剪保存照片格式：.png/.jpg'), "
        "('marriage_mode', '%1', '婚姻关系模式：modern(现代)/ancient(古代)'), "
        "('photo_display', 'with_photo', '照片显示模式：with_photo/no_photo');"
    ).arg(isModernMode ? "modern" : "ancient");

    // Insert default settings
    if (!query.exec( sql )) {
        qWarning() << "Failed to insert default settings:" << query.lastError().text();
        return false;
    }

    // Load settings
    loadSettings();

    // Settings initialization complete
    if (!m_initialized) {
        m_initialized = true;
        emit initializedChanged();
    }
    return true;
}

void SettingsManager::loadSettings()
{
    if (!m_db.isOpen()) {
        qWarning() << "Database not open";
        return;
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT setting_key, setting_value FROM user_settings");

    if (query.exec()) {
        while (query.next()) {
            QString key = query.value(0).toString();
            QString value = query.value(1).toString();
if (key == "photo_format") {
                m_photoFormat = value;
            } else if (key == "marriage_mode") {
                m_marriageMode = value;
            } else if (key == "photo_display") {
                m_photoDisplay = value;
            }
        }
        m_initialized = true;
        emit initializedChanged();
    } else {
        qWarning() << "Failed to load settings:" << query.lastError().text();
    }
}

bool SettingsManager::updateSetting(const QString& key, const QString& value)
{
    if (!m_db.isOpen()) {
        qWarning() << "Database not open";
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare("UPDATE user_settings SET setting_value = :value WHERE setting_key = :key");
    query.bindValue(":value", value);
    query.bindValue(":key", key);

    if (!query.exec()) {
        qWarning() << "Failed to update setting:" << query.lastError().text();
        return false;
    }

    return query.numRowsAffected() > 0;
}

bool SettingsManager::isInitialized() const
{
    return m_initialized;
}

QString SettingsManager::photoFormat() const
{
    return m_photoFormat;
}

QString SettingsManager::marriageMode() const
{
    return m_marriageMode;
}

QString SettingsManager::photoDisplay() const
{
    return m_photoDisplay;
}

QVariant SettingsManager::getSetting(const QString& key, const QVariant& defaultValue)
{
    if (!m_db.isOpen()) {
        qWarning() << "Database not open";
        return defaultValue;
    }

    QSqlQuery query(m_db);
    query.prepare("SELECT setting_value FROM user_settings WHERE setting_key = :key");
    query.bindValue(":key", key);

    if (query.exec() && query.next()) {
        return query.value(0);
    }

    return defaultValue;
}

void SettingsManager::setPhotoFormat(const QString& format)
{
    if (m_photoFormat != format) {
        if (updateSetting("photo_format", format)) {
            m_photoFormat = format;
            emit photoFormatChanged();
            emit settingChanged("photo_format", format);
        }
    }
}

void SettingsManager::setMarriageMode(const QString& mode)
{
    if (m_marriageMode != mode) {
        if (updateSetting("marriage_mode", mode)) {
            m_marriageMode = mode;
            emit marriageModeChanged();
            emit settingChanged("marriage_mode", mode);
        }
    }
}

void SettingsManager::setPhotoDisplay(const QString& display)
{
    if (m_photoDisplay != display) {
        if (updateSetting("photo_display", display)) {
            m_photoDisplay = display;
            emit photoDisplayChanged();
            emit settingChanged("photo_display", display);
        }
    }
}

void SettingsManager::setInitialized(bool status)
{
    if (m_initialized != status) {
        m_initialized = status;
        emit initializedChanged();
    }
}

bool SettingsManager::setSetting(const QString& key, const QVariant& value)
{
    bool result = updateSetting(key, value.toString());

    if (result) {
        // Update cached values
        if (key == "photo_format") {
            m_photoFormat = value.toString();
            emit photoFormatChanged();
        } else if (key == "marriage_mode") {
            m_marriageMode = value.toString();
            emit marriageModeChanged();
        } else if (key == "photo_display") {
            m_photoDisplay = value.toString();
            emit photoDisplayChanged();
        }

        emit settingChanged(key, value);
    }

    return result;
}

bool SettingsManager::resetToDefaults()
{
    if (!m_db.isOpen()) {
        qWarning() << "Database not open";
        return false;
    }

    QSqlQuery query(m_db);

    // Reset to default values
    if (!query.exec("UPDATE user_settings SET setting_value = CASE "
                    "WHEN setting_key = 'photo_format' THEN '.png' "
                    "WHEN setting_key = 'photo_display' THEN 'with_photo' "
                    "ELSE setting_value END")) {
        qWarning() << "Failed to reset settings:" << query.lastError().text();
        return false;
    }

    // Reload settings
    loadSettings();

    // Emit all signals
    emit photoFormatChanged();
    emit marriageModeChanged();
    emit photoDisplayChanged();

    return true;
}
