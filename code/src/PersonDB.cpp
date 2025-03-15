#include "PersonDB.h"
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QQmlEngine>

PersonInfo::PersonInfo()
{
    _id = -1;
    _protagonist = false;
    _name = "";
    _avatarPath = "";
    _gender = false;
    _call = "";
    _subCall = "";
    _birthday = "";
    _birthTraditional = false;
    _fRanking = 0;
    _mRanking = 0;
    _isDead = false;
    _deathTraditional = false;
    _death = "";
    _notes = "";
    _father = -1;
    _mother = -1;
}

PersonInfo::PersonInfo(const PersonInfo& _p)
{
    _id = _p._id;
    _protagonist = _p._protagonist;
    _name = _p._name;
    _avatarPath = _p._avatarPath;
    _gender = _p._gender;
    _call = _p._call;
    _subCall = _p._subCall;
    _birthday = _p._birthday;
    _birthTraditional = _p._birthTraditional;
    _fRanking = _p._fRanking;
    _mRanking = _p._mRanking;
    _isDead = _p._isDead;
    _deathTraditional = _p._deathTraditional;
    _death = _p._death;
    _notes = _p._notes;
    _father = _p._father;
    _mother = _p._mother;
    _children = _p._children;
    _marriages = _p._marriages;
}


const PersonInfo& PersonInfo::operator=(const PersonInfo& _p)
{
    return _p;
}

PersonDB::PersonDB()
{
    QQmlEngine::setObjectOwnership(&m_settings, QQmlEngine::CppOwnership);
    qDebug() << "PersonDB inited.\r\n";
}


PersonDB::~PersonDB()
{
    qDebug() << "~PersonDB start.\r\n";
    clearDB();
    qDebug() << "~PersonDB end.\r\n";
}


// QList<int> PersonDB::str2qlist(QString str)
// {
//     qDebug() << "str2qlist: " << str;
//     // QJsonParseError *error = new QJsonParseError();
//     QJsonParseError error;
//     QJsonDocument jsonDoc = QJsonDocument::fromJson(str.toUtf8(), &error);
//     if (!jsonDoc.isArray()) {
//         qWarning("JSON is not an array");
//         qDebug() << error.errorString();
//         return QList<int>(); // 返回空列表
//     }
//     // 获取JSON数组
//     QJsonArray jsonArray = jsonDoc.array();

//     QList<int> list;
//     for (const QJsonValue &value : jsonArray) {
//         if (value.isString()) {
//             list.append(value.toInt());
//         } else {
//             qWarning("JSON array contains non-string values");
//         }
//     }

//     return list;
// }


bool PersonDB::str2qlist(QList<int>* list, QString str)
{
    if (str.isEmpty()) {
        qDebug() << "[str2qlist] str is empty.";
        return false;
    }

    list->clear();
    QStringList items = str.split(",");

    for (const QString& item : items) {
        bool ok;
        int value = item.trimmed().toInt(&ok);
        if (ok) {
            list->append(value);
        }
    }

    return true;
}


QString PersonDB::qlist2str(const QList<int>* li)
{
    if (li->count() == 0)
        return "";

    QString str;

    for (const auto& value : *li) {
        str += QString::number(value) + ",";
    }

    return str;
}


bool PersonDB::newMap(const QString path, const QString name)
{
    QString mapPath = path + "/" + name;
    QString mapFile = mapPath + "/" + name + ".sqlite3";

    if (QDir().mkdir(mapPath)) {
        qDebug() << "文件夹创建成功！";
    } else {
        qDebug() << "文件夹创建失败！";
        return false;
    }

    return initDB(mapFile);
}


bool PersonDB::initDB(const QString filePath)
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(filePath);
    if (!db.open()) {
        qDebug() << "Error: Unable to open database!" << db.lastError().text();
        return false;
    }
    qDebug() << "Database opened successfully:" << filePath;

    QSqlQuery query;
    QString createTableSQL = "CREATE TABLE IF NOT EXISTS person_list ("
                             "id    INTEGER NOT NULL UNIQUE,"
                             "protagonist   BLOB,"
                             "name  TEXT,"
                             "avatar_path    TEXT,"
                             "gender    BLOB NOT NULL,"
                             "call  TEXT,"
                             "sub_call   TEXT,"
                             "birthday  TEXT,"
                             "birth_trad  BLOB,"
                             "f_rank  INTEGER,"
                             "m_rank  INTEGER,"
                             "is_dead    BLOB,"
                             "death_trad  BLOB,"
                             "death TEXT,"
                             "notes TEXT,"
                             "father    INTEGER,"
                             "mother    INTEGER,"
                             "children  TEXT,"
                             "marriages TEXT,"
                             "PRIMARY KEY(id AUTOINCREMENT)"
                             ");";
    qDebug().noquote() << createTableSQL;

    if (!query.exec(createTableSQL)) {
        qDebug() << "Failed to create table person_list:" << query.lastError().text();
        db.close();
        return false;
    }
    qDebug() << "Table created person_list successfully!";

    // 初始化设置管理器
    m_settings.setDatabase(db);
    if (!m_settings.initSettingsTable()) {
        qWarning() << "Failed to initialize settings table";
        db.close();
        return false;
    }

    return true;
}


void PersonDB::clearDB()
{
    m_errorMsg = "";
    m_protagonistId = -1;
    for (int i = 0; i < m_personList.length(); i++) {
        if (m_personList[i])
            delete m_personList[i];
    }
    m_personList.clear();
}


bool PersonDB::loadDB(QString dbPath)
{
    if (m_pDb.isOpen()) {
        clearDB();
        m_pDb.close();
    }

    //建立并打开数据库
    // if (QSqlDatabase::contains("qt_sql_default_connection")) {
    //     m_pDb = QSqlDatabase::database("qt_sql_default_connection");
    // } else {
    //     m_pDb = QSqlDatabase::addDatabase("QSQLITE");
    // }

    m_pDb = QSqlDatabase::addDatabase("QSQLITE");
    m_pDb.setDatabaseName(dbPath);
    if (!m_pDb.open()) {
        qDebug() << "Error: Failed to connect database." << m_pDb.lastError().text();
        return false;
    }
    m_settings.setDatabase(m_pDb);
    m_settings.loadSettings();

    int pidCount = 0;
    QSqlQuery sqlQuery;
    if (sqlQuery.exec("select * from person_list")) {
        int index;
        while (sqlQuery.next()) {
            int pid = sqlQuery.value(0).toInt();
            while (pid != pidCount) {
                qDebug() << "Make null ptr:" << pidCount;
                m_personList.push_back(nullptr);
                pidCount++;
            }
            pidCount++;

            PersonInfo* p = new PersonInfo();
            QQmlEngine::setObjectOwnership(p, QQmlEngine::CppOwnership);
            p->_id = pid;
            index = 1;
            p->_protagonist = sqlQuery.value(index++).toBool();
            if (p->_protagonist)
                m_protagonistId = pid;
            p->_name = sqlQuery.value(index++).toString();
            p->_avatarPath = sqlQuery.value(index++).toString();
            p->_gender = sqlQuery.value(index++).toBool();
            p->_call = sqlQuery.value(index++).toString();
            p->_subCall = sqlQuery.value(index++).toString();
            p->_birthday = sqlQuery.value(index++).toString();
            p->_birthTraditional = sqlQuery.value(index++).toBool();
            p->_fRanking = sqlQuery.value(index++).toInt();
            p->_mRanking = sqlQuery.value(index++).toInt();
            p->_isDead = sqlQuery.value(index++).toBool();
            p->_deathTraditional = sqlQuery.value(index++).toBool();
            p->_death = sqlQuery.value(index++).toString();
            p->_notes = sqlQuery.value(index++).toString();
            p->_father = sqlQuery.value(index++).toInt();
            p->_mother = sqlQuery.value(index++).toInt();
            QString children_str = sqlQuery.value(index++).toString();
            str2qlist(&p->_children, children_str);
            QString marriageStr = sqlQuery.value(index++).toString();
            str2qlist(&p->_marriages, marriageStr);
            qDebug() << "LoadDB person: " << p->_name ;
            m_personList.push_back(p);
        }
    } else {
        qDebug() << "Failed get Person List." << sqlQuery.lastError().text();
        return false;
    }

    qDebug() << "PersonDB loaded.\r\n";
    return true;
}


PersonInfo* PersonDB::newFirstPerson()
{
    PersonInfo* p = getNextNewPerson();
    p->_protagonist = 1;
    m_protagonistId = p->_id;
    p->_gender = 1;
    p->_marriages.append(-1);

    if (addPerson(p))
        return p;
    else
        return nullptr;
}


PersonInfo* PersonDB::getPersonByName(QString name)
{
    for (int i = 0; i < m_personList.length(); i++) {
        if (m_personList[i] != nullptr && m_personList[i]->_name == name) {
            return m_personList[i];
        }
    }
    return nullptr;
}


PersonInfo* PersonDB::getPerson(int index)
{
    if (index < 0 || index >= m_personList.length())
        return nullptr;
    qDebug() << "Get person:" << index << m_personList[index]->_name;
    return m_personList[index];
}


int PersonDB::getProtagonistId()
{
    // int index = 0;
    // for (; index < m_personList.count(); index++) {
    //     if (m_personList[index]->_protagonist)
    //         break;
    // }
    return m_protagonistId;
}


PersonInfo* PersonDB::getProtagonist()
{
    // int index = 0;
    // for (; index < m_personList.count(); index++) {
    //     if (m_personList[index]->_protagonist)
    //         break;
    // }
    return getPerson(m_protagonistId);
}


bool PersonDB::setProtagonist(int id)
{
    if (id >= 0 && id < m_personList.length()) {
        m_personList[m_protagonistId]->_protagonist = 0;
        updatePerson(m_protagonistId);
        m_personList[id]->_protagonist = 1;
        m_protagonistId = id;
        updatePerson(id);
    }
    return true;
}


PersonInfo* PersonDB::getNextNewPerson()
{
    for (int i = 1; i < m_personList.count(); i++) {
        if (m_personList[i] == nullptr) {
            m_personList[i] = new PersonInfo();
            QQmlEngine::setObjectOwnership(m_personList[i], QQmlEngine::CppOwnership);
            m_personList[i]->_avatarPath = "icons/person.svg";
            m_personList[i]->_id = i;
            return m_personList[i];
        }
    }

    PersonInfo* p = new PersonInfo();
    QQmlEngine::setObjectOwnership(p, QQmlEngine::CppOwnership);
    p->_avatarPath = "icons/person.svg";
    p->_id = m_personList.count();
    m_personList.append(p);
    return p;
}


PersonInfo* PersonDB::addFather(const int index)
{
    PersonInfo* p = getNextNewPerson();
    p->_gender = 1;
    p->_children.append(index);
    p->_marriages.append(-1);

    if (addPerson(p)) {
        // Appending to a QList may cause items to move, and the rvalue might be null.
        m_personList[index]->_father = p->_id;
        updatePerson(index);
        return p;
    } else
        return nullptr;
}


PersonInfo* PersonDB::getFather(const int index)
{
    return m_personList[m_personList[index]->_father];
}


PersonInfo* PersonDB::addMother(const int index)
{
    PersonInfo* p = getNextNewPerson();
    p->_gender = 0;
    p->_children.push_back(index);
    p->_marriages.append(-1);

    if (addPerson(p)) {
        m_personList[index]->_mother = p->_id;
        updatePerson(index);
        return p;
    } else
        return nullptr;
}


PersonInfo* PersonDB::getMother(const int index)
{
    return m_personList[m_personList[index]->_mother];
}


PersonInfo* PersonDB::addMate(const int index)
{
    PersonInfo* p = getNextNewPerson();
    p->_gender = !m_personList[index]->_gender;
    p->_marriages.push_back(index);

    if (addPerson(p)) {
        if (m_personList[index]->_marriages.count() > 0)
            m_personList[index]->_marriages[0] = p->_id;
        else
            m_personList[index]->_marriages.push_back(p->_id);
        updatePerson(index);
        return p;
    } else
        return nullptr;
}


PersonInfo* PersonDB::addEx(const int index)
{
    PersonInfo* p = getNextNewPerson();
    p->_gender = !m_personList[index]->_gender;
    p->_marriages.push_back(-1);
    p->_marriages.push_back(index);

    if (addPerson(p)) {
        if (m_personList[index]->_marriages.count() == 0)
            p->_marriages.push_back(-1);
        m_personList[index]->_marriages.push_back(p->_id);
        updatePerson(index);
        return p;
    } else
        return nullptr;
}


PersonInfo* PersonDB::addSon(const int index)
{
    PersonInfo* p = getNextNewPerson();
    p->_gender = true;
    if (m_personList[index]->_gender)
        p->_father = index;
    else
        p->_mother = index;
    p->_marriages.append(-1);

    if (addPerson(p))
        return p;
    else
        return nullptr;
}


PersonInfo* PersonDB::addDaughter(const int index)
{
    PersonInfo* p = getNextNewPerson();
    p->_gender = false;
    if (m_personList[index]->_gender)
        p->_father = index;
    else
        p->_mother = index;
    p->_marriages.append(-1);

    if (addPerson(p))
        return p;
    else
        return nullptr;
}

int PersonDB::getPersonLinks(const PersonInfo* p)
{
    int links = 0;
    if (p->_father != -1)
        links++;
    if (p->_mother != -1)
        links++;

    links += p->_children.count();

    if (p->_marriages.count() == 1 && p->_marriages[0] != -1)
        links++;
    else {
        links += p->_marriages.count();
        if (p->_marriages[0] == -1)
            links--;
    }
    return links;
}

// @return true:Can be delete  false:Can't be delete
bool PersonDB::delPersonCheck(const PersonInfo* p)
{
    if (p->_id == getProtagonistId() && m_personList.length() > 2) {
        m_errorMsg = "主人公仅在最后可删除!";
        return false;
    }

    if (getPersonLinks(p) <= 1)
        return true;

    if (p->_father != -1 && getPersonLinks(getPerson(p->_father)) <= 1) {
        m_errorMsg = "可能造成无法显示的人员:" + getPerson(p->_father)->_name +
                     "，请先删除此人员！";
        return false;
    }

    if (p->_mother != -1 && getPersonLinks(getPerson(p->_mother)) <= 1) {
        m_errorMsg = "可能造成无法显示的人员:" + getPerson(p->_mother)->_name +
                     "，请先删除此人员！";
        return false;
    }

    for (int i = 0; i < p->_marriages.length(); i++) {
        if (p->_marriages[i] != -1 && getPersonLinks(getPerson(p->_marriages[i])) <= 1) {
            m_errorMsg = "可能造成无法显示的人员:" + getPerson(p->_marriages[i])->_name +
                         "，请先删除此人员！";
            return false;
        }
    }

    for (int i = 0; i < p->_children.length(); i++) {
        if (getPersonLinks(getPerson(p->_children[i])) <= 1) {
            m_errorMsg = "可能造成无法显示的人员:" + getPerson(p->_children[i])->_name +
                         "，请先删除此人员！";
            return false;
        }
    }

    return true;
}


bool PersonDB::delPerson(int index)
{
    if (m_personList[index]->_protagonist && m_personList.count() != 1) {
        m_errorMsg = "主人公最后删除！";
        return false;
    }

    PersonInfo* p = m_personList[index];

    // if(!delPersonCheck(p))
    // {
    //     qDebug() << "checkForDelete false.\r\n";
    //     return false;
    // }
    // qDebug() << "checkForDelete true.\r\n";

    // Clear related person connect info
    if (p->_father != -1) {
        if (m_personList[p->_father]->_children.removeOne(index) > 0) {
            qDebug() << p->_father << " removed children " << index;
            updatePerson(p->_father);
        }
    }
    if (p->_mother != -1) {
        if (m_personList[p->_mother]->_children.removeOne(index) > 0) {
            qDebug() << p->_mother << " removed children " << index;
            updatePerson(p->_mother);
        }
    }
    qDebug() << "clear marriages";
    for (int n = 0; n < p->_marriages.count(); n++) {
        if (n == 0) {
            if (p->_marriages[0] != -1) {
                m_personList[p->_marriages[0]]->_marriages[0] = -1;
                updatePerson(p->_marriages[0]);
            }
        } else {
            m_personList[p->_marriages[n]]->_marriages.removeOne(p->_id);
            updatePerson(p->_marriages[n]);
        }
    }
    qDebug() << "clear children";
    for (const int n : p->_children) {
        if (p->_gender) {
            m_personList[n]->_father = -1;
        } else
            m_personList[n]->_mother = -1;
        updatePerson(n);
    }

    // Delete immediately
    delPersonDB(index);
    delete m_personList[index];
    if (index == (m_personList.count() - 1)) {
        qDebug() << "m_personList.removeLast()" ;
        m_personList.removeLast();
    } else {
        qDebug() << "m_personList[index] = nullptr" ;
        m_personList[index] = nullptr;
    }

    return true;
}


bool PersonDB::addPerson(PersonInfo* p)
{
    QString marriages_str = qlist2str(&p->_marriages);
    QString sqlStr = QString("INSERT INTO person_list VALUES (" + QString::number(p->_id) +
                             ", " + QString::number(p->_protagonist) +
                             ", \"" + p->_name +
                             "\", \"" + p->_avatarPath +
                             "\", " + QString::number(p->_gender) +
                             ", \"" + p->_call +
                             "\", \"" + p->_subCall +
                             "\", \"" + p->_birthday +
                             "\", " + QString::number(p->_birthTraditional) +
                             ", " + QString::number(p->_fRanking) +
                             ", " + QString::number(p->_mRanking) +
                             ", " + QString::number(p->_isDead) +
                             ", " + QString::number(p->_deathTraditional) +
                             ", \"" + p->_death +
                             "\", \"" + p->_notes +
                             "\", " + QString::number(p->_father) +
                             ", " + QString::number(p->_mother) +
                             ", \"" + qlist2str(&p->_children) +
                             "\", \"" + marriages_str +
                             "\");");

    qDebug().noquote() << sqlStr;
    QSqlQuery sqlQuery;
    if (sqlQuery.exec(sqlStr)) {
        // emit personListChanged();
        return true;
    }

    qDebug() << "Failed add Person." << sqlQuery.lastError().text();
    if (p->_id == m_personList.count() - 1)
        m_personList.removeLast();
    else
        m_personList[p->_id] = nullptr;
    delete p;

    return false;
}


int PersonDB::parentIsSync(int index)
{
    const PersonInfo* p = m_personList[index];

    if (p->_father == -1 && p->_mother == -1)
        return -3;
    if (p->_father == -1)
        return -1;
    if (p->_mother == -1)
        return -2;

    const PersonInfo* father = m_personList[p->_father];
    const PersonInfo* mother = m_personList[p->_mother];
    if (father->_children != mother->_children)
        return 1;

    return 0;
}

bool PersonDB::updatePerson(int index)
{
    const PersonInfo* p = m_personList[index];
    QString sqlStr = QString("UPDATE person_list SET protagonist = " + QString::number(
                                 p->_protagonist) +
                             ",name = \"" + p->_name +
                             "\",avatar_path = \"" + p->_avatarPath +
                             "\",gender = " + QString::number(p->_gender) +
                             ",call = \"" + p->_call +
                             "\",sub_call = \"" + p->_subCall +
                             "\",birthday = \"" + p->_birthday +
                             "\",birth_trad = " + QString::number(p->_birthTraditional) +
                             ",f_rank = " + QString::number(p->_fRanking) +
                             ",m_rank = " + QString::number(p->_mRanking) +
                             ",is_dead = " + QString::number(p->_isDead) +
                             ",death_trad = " + QString::number(p->_deathTraditional) +
                             ",death = \"" + p->_death +
                             "\",notes = \"" + p->_notes +
                             "\",father = " + QString::number(p->_father) +
                             ",mother = " + QString::number(p->_mother) +
                             ",children = \"" + qlist2str(&p->_children) +
                             "\",marriages = \"" + qlist2str(&p->_marriages) +
                             "\" WHERE id=" + QString::number(p->_id) +
                             ";");

    qDebug().noquote() << sqlStr;
    QSqlQuery sqlQuery;
    if (sqlQuery.exec(sqlStr)) {
        return true;
    }

    qDebug() << "Failed update Person." << sqlQuery.lastError().text();
    return false;
}


bool PersonDB::updateMRanking(const int pid, const int ranking)
{
    m_personList[pid]->_mRanking = ranking;
    QString sqlStr = QString("UPDATE person_list SET "
                             "m_rank = " + QString::number(ranking) +
                             " WHERE id=" + QString::number(pid) +
                             ";");

    qDebug().noquote() << sqlStr;
    QSqlQuery sqlQuery;
    if (sqlQuery.exec(sqlStr)) {
        return true;
    }

    qDebug() << "Failed update Person." << sqlQuery.lastError().text();
    return false;
}


bool PersonDB::updateFRanking(const int pid, const int ranking)
{
    m_personList[pid]->_fRanking = ranking;
    QString sqlStr = QString("UPDATE person_list SET "
                             "f_rank = " + QString::number(ranking) +
                             " WHERE id=" + QString::number(pid) +
                             ";");

    qDebug().noquote() << sqlStr;
    QSqlQuery sqlQuery;
    if (sqlQuery.exec(sqlStr)) {
        return true;
    }

    qDebug() << "Failed update Person." << sqlQuery.lastError().text();
    return false;
}


bool PersonDB::updateChildren(const int pid)
{
    QString sqlStr = QString("UPDATE person_list SET "
                             "children = \"" + qlist2str(&m_personList[pid]->_children) +
                             "\" WHERE id=" + QString::number(pid) +
                             ";");

    qDebug().noquote() << sqlStr;
    QSqlQuery sqlQuery;
    /*
    sqlQuery.prepare("UPDATE person_list SET children = :children WHERE id = :id");
    sqlQuery.bindValue(":children", qlist2str(&m_personList[pid]->_children));
    sqlQuery.bindValue(":id", pid);
    */
    if (sqlQuery.exec(sqlStr)) {
        return true;
    }

    qDebug() << "Failed update Person: " << sqlQuery.lastError().text();
    return false;
}


bool PersonDB::updateChildren(const int pid, const QString childrenStr)
{
    str2qlist(&m_personList[pid]->_children, childrenStr);
    QString sqlStr = QString("UPDATE person_list SET "
                             "children = \"" + childrenStr +
                             "\" WHERE id=" + QString::number(pid) +
                             ";");

    qDebug().noquote() << sqlStr;
    QSqlQuery sqlQuery;
    if (sqlQuery.exec(sqlStr)) {
        return true;
    }

    qDebug() << "Failed update Person: " << sqlQuery.lastError().text();
    return false;
}


bool PersonDB::delPersonDB(int id)
{
    QString sqlStr = QString("DELETE FROM person_list WHERE id = \"" + QString::number(id) + "\";");

    qDebug().noquote() << sqlStr;
    QSqlQuery sqlQuery;
    if (sqlQuery.exec(sqlStr)) {
        return true;
    }

    qDebug() << "Failed delete person " << sqlQuery.lastError().text();
    return false;
}
