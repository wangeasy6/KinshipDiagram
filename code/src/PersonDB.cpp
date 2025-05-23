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

bool PersonInfo::delConnection(int del_pid)
{
    if (_father == del_pid) {
        _father = -1;
        return true;
    }
    if (_mother == del_pid) {
        _mother = -1;
        return true;
    }

    for (int i = 0; i < _marriages.length(); i++) {
        if (_marriages[i] == del_pid) {
            if (i == 0)
                _marriages[0] = -1;
            else
                _marriages.remove(i, 1);
            return true;
        }
    }

    for (int i = 0; i < _children.length(); i++) {
        if (_children[i] == del_pid) {
            _children.remove(i, 1);
            return true;
        }
    }

    return false;
}


bool PersonDB::delConnection(int pid1, int pid2)
{
    PersonInfo* p1 = m_personList[pid1];
    PersonInfo* p2 = m_personList[pid2];
    qDebug() << "[delConnection]" << p1->_name << " : " << p2->_name;
    if (p1->delConnection(pid2)) {
        qDebug() << p1->_name << " delete: " << p2->_name;
        updatePerson(p1);
    }
    if (p2->delConnection(pid1)) {
        qDebug() << p2->_name << " delete: " << p1->_name;
        updatePerson(p2);
    }
    return true;
}


bool PersonDB::addConnection(PersonInfo* p, int to_pid, int type)
{
    PersonInfo* to_p = m_personList[to_pid];
    int q_index = -1;
    switch (type) {
    case 0:
        p->_father = to_pid;
        to_p->_children.append(p->_id);
        break;
    case 1:
        p->_mother = to_pid;
        to_p->_children.append(p->_id);
        break;
    case 2:
        p->_children.append(to_pid);
        if (p->_gender)
            to_p->_father = p->_id;
        else
            to_p->_mother = p->_id;
        break;
    case 3:
        p->_marriages[0] = to_pid;
        to_p->_marriages[0] = p->_id;
        break;
    case 4:
        q_index = p->_marriages.indexOf(-1, 1);
        if (q_index == -1)
            p->_marriages.append(to_pid);
        else
            p->_marriages.insert(q_index, to_pid);

        q_index = to_p->_marriages.indexOf(-1, 1);
        if (q_index == -1)
            to_p->_marriages.append(p->_id);
        else
            to_p->_marriages.insert(q_index, p->_id);
        break;
    case 5:
        if (p->_marriages.indexOf(-1, 1) == -1)
            p->_marriages.append(-1);
        p->_marriages.append(to_pid);
        to_p->_marriages[0] = p->_id;
        break;
    default:
        return false;
    }
    updatePerson(p);
    updatePerson(to_p);
    return true;
}

const PersonInfo& PersonInfo::operator=(const PersonInfo& _p)
{
    return _p;
}

PersonDB::PersonDB()
{
    QQmlEngine::setObjectOwnership(&m_settings, QQmlEngine::CppOwnership);
    m_pDb = QSqlDatabase::addDatabase("QSQLITE");
    qDebug() << "PersonDB inited.\r\n";
}


PersonDB::~PersonDB()
{
    qDebug() << "~PersonDB start.\r\n";
    if (m_pDb.isOpen()) {
        clearDB();
        m_pDb.close();
    }
    if (QSqlDatabase::contains("QSQLITE"))
        QSqlDatabase::removeDatabase("QSQLITE");
    qDebug() << "~PersonDB end.\r\n";
}


bool PersonDB::str2qlist(QList<int>* list, QString str)
{
    if (str.isEmpty()) {
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


bool PersonDB::newMap(const QString path, const QString name, bool isModernMode)
{
    QString mapPath = path + "/" + name;
    QString mapFile = mapPath + "/" + name + ".sqlite3";

    if (!QDir().mkdir(mapPath)) {
        qDebug() << "Folder creation failed: " << mapPath;
        return false;
    }

    return initDB(mapFile, isModernMode);
}


bool PersonDB::initDB(const QString filePath, bool isModernMode)
{
    m_pDb.setDatabaseName(filePath);
    if (!m_pDb.open()) {
        qDebug() << "Error: Unable to open database!" << m_pDb.lastError().text();
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
        m_pDb.close();
        return false;
    }
    qDebug() << "Table created person_list successfully!";

    // 初始化设置管理器
    m_settings.setDatabase(m_pDb);
    if (!m_settings.initSettingsTable(isModernMode)) {
        qWarning() << "Failed to initialize settings table";
        m_pDb.close();
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


bool PersonDB::checkMap(QString dbPath)
{
    if (m_pDb.isOpen()) {
        clearDB();
        m_pDb.close();
    }

    m_pDb.setDatabaseName(dbPath);
    if (!m_pDb.open()) {
        qDebug() << "Error: Failed to connect database." << m_pDb.lastError().text();
        return false;
    }

    QSqlQuery query;
    if (!query.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='person_list';") || !query.next()) {
        qDebug() << "Failed get table person_list." << query.lastError().text();
        m_pDb.close();
        return false;
    }

    if (!query.exec("SELECT name  FROM sqlite_master  WHERE type='table' AND name='user_settings';") || !query.next()) {
        qDebug() << "Failed get table user_settings." << query.lastError().text();
        m_pDb.close();
        return false;
    }

    m_pDb.close();
    return true;
}


bool PersonDB::loadDB(QString dbPath)
{
    if (m_pDb.isOpen()) {
        clearDB();
        m_pDb.close();
    }

    m_pDb.setDatabaseName(dbPath);
    if (!m_pDb.open()) {
        qDebug() << "Error: Failed to connect database." << m_pDb.lastError().text();
        return false;
    }

    m_settings.setDatabase(m_pDb);
    m_settings.loadSettings();

    int pidCount = 0;
    QSqlQuery query;
    if (query.exec("select * from person_list")) {
        int index;
        while (query.next()) {
            int pid = query.value(0).toInt();
            while (pid != pidCount) {
                // qDebug() << "Make null ptr:" << pidCount;
                m_personList.push_back(nullptr);
                pidCount++;
            }
            pidCount++;

            PersonInfo* p = new PersonInfo();
            QQmlEngine::setObjectOwnership(p, QQmlEngine::CppOwnership);
            p->_id = pid;
            index = 1;
            p->_protagonist = query.value(index++).toBool();
            if (p->_protagonist)
                m_protagonistId = pid;
            p->_name = query.value(index++).toString();
            p->_avatarPath = query.value(index++).toString();
            p->_gender = query.value(index++).toBool();
            p->_call = query.value(index++).toString();
            p->_subCall = query.value(index++).toString();
            p->_birthday = query.value(index++).toString();
            p->_birthTraditional = query.value(index++).toBool();
            p->_fRanking = query.value(index++).toInt();
            p->_mRanking = query.value(index++).toInt();
            p->_isDead = query.value(index++).toBool();
            p->_deathTraditional = query.value(index++).toBool();
            p->_death = query.value(index++).toString();
            p->_notes = query.value(index++).toString();
            p->_father = query.value(index++).toInt();
            p->_mother = query.value(index++).toInt();
            QString children_str = query.value(index++).toString();
            str2qlist(&p->_children, children_str);
            QString marriageStr = query.value(index++).toString();
            str2qlist(&p->_marriages, marriageStr);
            // qDebug() << "LoadDB person: " << p->_name ;
            m_personList.push_back(p);
        }
    } else {
        qDebug() << "Failed get Person List." << query.lastError().text();
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

    // qDebug() << "Get person:" << index << m_personList[index]->_name;
    return m_personList[index];
}


int PersonDB::getProtagonistId()
{
    return m_protagonistId;
}


PersonInfo* PersonDB::getProtagonist()
{
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
            m_personList[index]->_marriages.push_back(-1);

        if (getSettings()->isAncientMode() && m_personList[index]->_gender) { // Ancient Man
            int q_index = m_personList[index]->_marriages.indexOf(-1, 1);
            if (q_index != -1)
                m_personList[index]->_marriages.insert(q_index, p->_id);
            else
                m_personList[index]->_marriages.push_back(p->_id);
        } else {
            m_personList[index]->_marriages.push_back(p->_id);
        }
        updatePerson(index);
        return p;
    }

    return nullptr;
}


PersonInfo* PersonDB::addConcubine(const int index)
{
    // Only for ancient man
    if (getSettings()->isModernMode() || !m_personList[index]->_gender)
        return nullptr;

    PersonInfo* p = getNextNewPerson();
    p->_gender = !m_personList[index]->_gender;
    p->_marriages.push_back(index);

    if (addPerson(p)) {
        if (m_personList[index]->_marriages.count() == 0)
            m_personList[index]->_marriages.push_back(-1);
        int q_index = m_personList[index]->_marriages.indexOf(-1, 1);
        if (q_index == -1)
            m_personList[index]->_marriages.push_back(-1);
        m_personList[index]->_marriages.push_back(p->_id);
        updatePerson(index);
        return p;
    }

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
        m_errorMsg = tr("主人公仅在最后可删除!");
        return false;
    }

    if (getPersonLinks(p) <= 1)
        return true;

    if (p->_father != -1 && getPersonLinks(getPerson(p->_father)) <= 1) {
        m_errorMsg = tr("可能造成人员无法显示，\r\n请先删除: ") + getPerson(p->_father)->_name;
        return false;
    }

    if (p->_mother != -1 && getPersonLinks(getPerson(p->_mother)) <= 1) {
        m_errorMsg = tr("可能造成人员无法显示，\r\n请先删除: ") + getPerson(p->_mother)->_name;
        return false;
    }

    for (int i = 0; i < p->_marriages.length(); i++) {
        if (p->_marriages[i] != -1 && getPersonLinks(getPerson(p->_marriages[i])) <= 1) {
            m_errorMsg = tr("可能造成人员无法显示，\r\n请先删除: ") + getPerson(p->_marriages[i])->_name;
            return false;
        }
    }

    for (int i = 0; i < p->_children.length(); i++) {
        if (getPersonLinks(getPerson(p->_children[i])) <= 1) {
            m_errorMsg = tr("可能造成人员无法显示，\r\n请先删除: ") + getPerson(p->_children[i])->_name;
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
        m_personList.removeLast();
    } else {
        m_personList[index] = nullptr;
    }

    return true;
}


// 修改 addPerson 方法中的SQL语句
bool PersonDB::addPerson(PersonInfo* p)
{
    QSqlQuery query;
    query.prepare("INSERT INTO person_list VALUES (:id, :protagonist, :name, :avatar_path, :gender, :call, :sub_call, :birthday, :birth_trad, :f_rank, :m_rank, :is_dead, :death_trad, :death, :notes, :father, :mother, :children, :marriages)");
    query.bindValue(":id", p->_id);
    query.bindValue(":protagonist", p->_protagonist);
    query.bindValue(":name", p->_name);
    query.bindValue(":avatar_path", p->_avatarPath);
    query.bindValue(":gender", p->_gender);
    query.bindValue(":call", p->_call);
    query.bindValue(":sub_call", p->_subCall);
    query.bindValue(":birthday", p->_birthday);
    query.bindValue(":birth_trad", p->_birthTraditional);
    query.bindValue(":f_rank", p->_fRanking);
    query.bindValue(":m_rank", p->_mRanking);
    query.bindValue(":is_dead", p->_isDead);
    query.bindValue(":death_trad", p->_deathTraditional);
    query.bindValue(":death", p->_death);
    query.bindValue(":notes", p->_notes);
    query.bindValue(":father", p->_father);
    query.bindValue(":mother", p->_mother);
    query.bindValue(":children", qlist2str(&p->_children));
    query.bindValue(":marriages", qlist2str(&p->_marriages));
    query.bindValue(":id", p->_id);

    if (query.exec()) {
        // emit personListChanged();
        return true;
    }

    qDebug() << "Failed add Person." << query.lastError().text();
    qDebug().noquote() << query.lastQuery();

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

bool PersonDB::updatePerson(const PersonInfo* p)
{
    QSqlQuery query;
    query.prepare("UPDATE person_list SET protagonist = :protagonist, name = :name, avatar_path = :avatar_path, gender = :gender, call = :call, sub_call = :sub_call, birthday = :birthday, birth_trad = :birth_trad, f_rank = :f_rank, m_rank = :m_rank, is_dead = :is_dead, death_trad = :death_trad, death = :death, notes = :notes, father = :father, mother = :mother, children = :children, marriages = :marriages WHERE id = :id");
    query.bindValue(":protagonist", p->_protagonist);
    query.bindValue(":name", p->_name);
    query.bindValue(":avatar_path", p->_avatarPath);
    query.bindValue(":gender", p->_gender);
    query.bindValue(":call", p->_call);
    query.bindValue(":sub_call", p->_subCall);
    query.bindValue(":birthday", p->_birthday);
    query.bindValue(":birth_trad", p->_birthTraditional);
    query.bindValue(":f_rank", p->_fRanking);
    query.bindValue(":m_rank", p->_mRanking);
    query.bindValue(":is_dead", p->_isDead);
    query.bindValue(":death_trad", p->_deathTraditional);
    query.bindValue(":death", p->_death);
    query.bindValue(":notes", p->_notes);
    query.bindValue(":father", p->_father);
    query.bindValue(":mother", p->_mother);
    query.bindValue(":children", qlist2str(&p->_children));
    query.bindValue(":marriages", qlist2str(&p->_marriages));
    query.bindValue(":id", p->_id);

    if (query.exec()) {
        qDebug() << "Update person success: " << p->_name;
        return true;
    }

    qDebug() << "Failed update Person." << query.lastError().text();
    qDebug().noquote() << query.lastQuery();
    return false;
}

bool PersonDB::updatePerson(int pid)
{
    const PersonInfo* p = m_personList[pid];
    return updatePerson(p);
}


bool PersonDB::updateMRanking(const int pid, const int ranking)
{
    m_personList[pid]->_mRanking = ranking;

    QSqlQuery query;
    query.prepare("UPDATE person_list SET m_rank = :m_rank WHERE id = :id");
    query.bindValue(":m_rank", ranking);
    query.bindValue(":id", pid);

    if (query.exec()) {
        return true;
    }

    qDebug() << "Failed update Person." << query.lastError().text();
    qDebug().noquote() << query.lastQuery();
    return false;
}


bool PersonDB::updateFRanking(const int pid, const int ranking)
{
    m_personList[pid]->_fRanking = ranking;

    QSqlQuery query;
    query.prepare("UPDATE person_list SET f_rank = :f_rank WHERE id = :id");
    query.bindValue(":f_rank", ranking);
    query.bindValue(":id", pid);

    if (query.exec()) {
        return true;
    }

    qDebug() << "Failed update Person." << query.lastError().text();
    qDebug().noquote() << query.lastQuery();
    return false;
}


bool PersonDB::updateChildren(const int pid)
{
    return updateChildren(pid, qlist2str(&m_personList[pid]->_children));
}


bool PersonDB::updateChildren(const int pid, const QString childrenStr)
{
    QSqlQuery query;
    query.prepare("UPDATE person_list SET children = :children WHERE id = :id");
    query.bindValue(":children", childrenStr);
    query.bindValue(":id", pid);

    if (query.exec()) {
        return true;
    }

    qDebug() << "Failed update Person: " << query.lastError().text();
    qDebug().noquote() << query.lastQuery();
    return false;
}


bool PersonDB::adjustMarriageRanking(PersonInfo* p, int pid, int shift)
{
    if (!p || !p->_marriages.contains(pid))
        return false;

    int currentIndex = p->_marriages.indexOf(pid);
    int newIndex = currentIndex - shift;
    if (newIndex < 1 || p->_marriages.count() <= newIndex)
        return false;

    p->_marriages.move(currentIndex, newIndex);

    return updatePerson(p);
}


bool PersonDB::adjustChildrenRanking(PersonInfo* p, int pid, int shift)
{
    if (!p || !p->_children.contains(pid))
        return false;

    int currentIndex = p->_children.indexOf(pid);
    int newIndex = currentIndex - shift;
    if (newIndex < 0 || p->_children.count() <= newIndex)
        return false;

    p->_children.move(currentIndex, newIndex);

    return updateChildren(p->_id);
}


bool PersonDB::delPersonDB(int pid)
{
    QSqlQuery query;
    query.prepare("DELETE FROM person_list WHERE id = ?");
    query.addBindValue(pid);

    if (query.exec()) {
        return true;
    }

    qDebug() << "Failed delete Person: " << query.lastError().text();
    qDebug().noquote() << query.lastQuery();
    return false;
}
