#ifndef PERSONDB_H
#define PERSONDB_H

#include <QObject>
#include <QSqlDatabase>
#include <QDebug>
#include <QQmlListProperty>
#include "SettingsManager.h"


class PersonInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id MEMBER _id CONSTANT)
    Q_PROPERTY(QString name MEMBER _name NOTIFY nameChanged)
    // Q_PROPERTY(QString avatarPath READ avatarPath WRITE setAvatarPath NOTIFY avatarPathChanged)
    Q_PROPERTY(QString avatarPath MEMBER _avatarPath NOTIFY avatarPathChanged)
    Q_PROPERTY(bool protagonist MEMBER _protagonist NOTIFY protagonistChanged)
    Q_PROPERTY(bool gender MEMBER _gender NOTIFY genderChanged)
    Q_PROPERTY(QString call MEMBER _call NOTIFY callChanged)
    Q_PROPERTY(QString subCall MEMBER _subCall NOTIFY subCallChanged)
    Q_PROPERTY(QString birthday MEMBER _birthday NOTIFY birthdayChanged)
    Q_PROPERTY(bool birthTraditional MEMBER _birthTraditional NOTIFY birthTraditionalChanged)
    Q_PROPERTY(int fRanking MEMBER _fRanking NOTIFY fRankingChanged)
    Q_PROPERTY(int mRanking MEMBER _mRanking NOTIFY mRankingChanged)
    Q_PROPERTY(bool isDead MEMBER _isDead NOTIFY isDeadChanged)
    Q_PROPERTY(bool deathTraditional MEMBER _deathTraditional NOTIFY deathTraditionalChanged)
    Q_PROPERTY(QString death MEMBER _death NOTIFY deathChanged)
    Q_PROPERTY(QString notes MEMBER _notes NOTIFY notesChanged)
    Q_PROPERTY(int father MEMBER _father NOTIFY fatherChanged)
    Q_PROPERTY(int mother MEMBER _mother NOTIFY motherChanged)
    Q_PROPERTY(QList<int> children MEMBER _children NOTIFY childrenChanged)
    Q_PROPERTY(QList<int> marriages MEMBER _marriages NOTIFY marriagesChanged)

public:
    PersonInfo();
    PersonInfo(const PersonInfo&);
    const PersonInfo& operator=(const PersonInfo&);

    int _id;
    bool _protagonist;
    QString _avatarPath;
    QString _name;
    bool _gender;
    QString _call;
    QString _subCall;
    QString _birthday;
    bool _birthTraditional;
    int _fRanking;
    int _mRanking;
    bool _isDead;
    bool _deathTraditional;
    QString _death;
    QString _notes;

    // Relationship
    int _father;
    int _mother;
    QList<int> _children;
    QList<int> _marriages;   // 默认 index 0 是正室，只有Ex没有正室则存 -1

private:
    static qsizetype childrenCount(QQmlListProperty<int>*);
    static int atChildren(QQmlListProperty<int>*, qsizetype);

signals:
    void nameChanged();
    void avatarPathChanged();
    void protagonistChanged();
    void genderChanged();
    void callChanged();
    void subCallChanged();
    void birthdayChanged();
    void birthTraditionalChanged();
    void fRankingChanged();
    void mRankingChanged();
    void isDeadChanged();
    void deathTraditionalChanged();
    void deathChanged();
    void notesChanged();
    void fatherChanged();
    void motherChanged();
    void childrenChanged();
    void marriagesChanged();
};


class PersonDB : public QObject
{
    Q_OBJECT

public:
    PersonDB();
    ~PersonDB();
    Q_INVOKABLE bool newMap(const QString path, const QString name);
    Q_INVOKABLE bool loadDB(QString person_db_path = "default.sqlite3");
    // Q_PROPERTY(SettingsManager settings MEMBER m_settings NOTIFY settingsChanged)
    Q_PROPERTY(QString error_msg READ errorMsg CONSTANT)
    Q_INVOKABLE PersonInfo* newFirstPerson();
    Q_INVOKABLE PersonInfo* getPersonByName(QString name);
    Q_INVOKABLE PersonInfo* getPerson(int index);
    Q_INVOKABLE int getProtagonistId();
    Q_INVOKABLE PersonInfo* getProtagonist();
    Q_INVOKABLE bool setProtagonist(int id);
    Q_INVOKABLE qsizetype personListCount() { return m_personList.count();};
    Q_INVOKABLE PersonInfo* addFather(const int index);
    Q_INVOKABLE PersonInfo* getFather(const int index);
    Q_INVOKABLE PersonInfo* addMother(const int index);
    Q_INVOKABLE PersonInfo* getMother(const int index);
    Q_INVOKABLE PersonInfo* addMate(const int index);
    Q_INVOKABLE PersonInfo* addEx(const int index);
    Q_INVOKABLE PersonInfo* addSon(const int index);
    Q_INVOKABLE PersonInfo* addDaughter(const int index);
    Q_INVOKABLE bool delPersonCheck(const PersonInfo* p);
    Q_INVOKABLE bool delPerson(int index);
    Q_INVOKABLE bool updatePerson(int index);
    bool addPerson(PersonInfo* p);
    // Judge whether the children of their parents are the same.
    Q_INVOKABLE int parentIsSync(int index);
    Q_INVOKABLE bool updateMRanking(const int pid, const int ranking);
    Q_INVOKABLE bool updateFRanking(const int pid, const int ranking);
    Q_INVOKABLE bool updateChildren(const int pid);
    Q_INVOKABLE bool updateChildren(const int pid, const QString childrenStr);
    QString errorMsg() {return m_errorMsg;};
    Q_INVOKABLE SettingsManager* getSettings() {return &m_settings;};

private:
    QSqlDatabase m_pDb;
    QString m_errorMsg;
    SettingsManager m_settings;
    int m_protagonistId = -1;
    QList<PersonInfo*> m_personList;
    bool str2qlist(QList<int>*, QString str);
    QString qlist2str(const QList<int>* li);
    bool delPersonDB(int id);
    int getPersonLinks(const PersonInfo* p);
    bool initDB(const QString);
    void clearDB();
    PersonInfo* getNextNewPerson();

signals:
    void settingsChanged();
};

#endif // PERSONDB_H
