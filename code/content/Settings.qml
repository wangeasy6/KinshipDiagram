import QtQuick 6.2
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import easy.qt.Settings 0.1

Popup {
    id: thisPage
    width: 1000
    height: 750
    anchors.centerIn: parent
    modal: true
    visible: true
    closePolicy: Popup.CloseOnEscape

    property int currentIndex: 0
    property var settingsManager: pdb.getSettings()

    // Prevent event penetration
    focus: true
    MouseArea {
        anchors.fill: parent
        Keys.onPressed: {
            event.accepted = true
        }
    }

    Component.onCompleted: {
        console.log("SettingsManager:", settingsManager)
        console.log("Language:", conf.language)
        console.log("PhotoFormat:", settingsManager.photoFormat)
        console.log("MarriageMode:", settingsManager.marriageMode)
        console.log("PhotoDisplay:", settingsManager.photoDisplay)
    }

    ToolButton {
        z: 1
        id: backButton
        anchors {
            right: parent.left
            top: parent.bottom
            rightMargin: -55
            topMargin: -55
        }
        width: 40
        height: 40
        icon.height: 30
        icon.width: 30
        icon.source: "icons/left-square.svg"
        display: AbstractButton.IconOnly
        ToolTip.text: qsTr("返回")
        ToolTip.delay: 500
        ToolTip.visible: hovered
        
        onClicked: thisPage.close()

        background: Rectangle {
            width: parent.width
            height: parent.height
            radius: 3
            color: backButton.hovered ? "#EA1E63" : "#95a5a6"
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        // 左侧菜单（宽度固定）
        Rectangle {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            color: "#2c3e50"

            Column {
                anchors.fill: parent
                spacing: 10
                padding: 10

                Repeater {
                    model: [qsTr("系统设置"), qsTr("图谱设置"), qsTr("我要反馈")]
                    delegate: Button {
                        width: parent.width - 20
                        height: 50
                        text: modelData
                        highlighted: currentIndex === index
                        onClicked: {
                            currentIndex = index
                            rightContent.sourceComponent = settingComponents[index]
                        }
                    }
                }
            }
        }

        // 右侧内容（带动画切换）
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f5f6fa"

            Loader {
                id: rightContent
                anchors.fill: parent
                anchors.margins: 20
                sourceComponent: settingComponents[currentIndex]
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
            }
        }
    }

    //
    Component {
        id: sysSettings
        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            enabled: conf

            GroupBox {
                title: qsTr("语言设置")
                Layout.fillWidth: true
                
                RowLayout {
                    RadioButton {
                        id: chineseCNRadio
                        text: qsTr("简体中文")
                        checked: conf ? conf.language === "zh-CN" : true
                        onClicked: {
                            conf.language = "zh-CN"
                        }
                    }
                    RadioButton {
                        id: chineseTWRadio
                        text: qsTr("繁体中文")
                        checked: conf ? conf.language === "zh-TW" : false
                        onClicked: {
                            conf.language = "zh-TW"
                        }
                    }
                    RadioButton {
                        id: englishRadio
                        text: "English"
                        visible: false
                        checked: conf ? conf.language === "en" : false
                        onClicked: {
                            conf.language = "en"
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    Component {
        id: mapSettings
        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            enabled: settingsManager.initialized

            GroupBox {
                title: qsTr("默认裁剪保存照片格式")
                Layout.fillWidth: true
                
                RowLayout {
                    RadioButton {
                        id: pngRadio
                        text: "PNG"
                        checked: settingsManager ? settingsManager.photoFormat === ".png" : false
                        onClicked: {
                            settingsManager.photoFormat = ".png"
                        }
                    }
                    RadioButton {
                        id: jpgRadio
                        text: "JPG"
                        checked: settingsManager ? settingsManager.photoFormat === ".jpg" : false
                        onClicked: {
                            settingsManager.photoFormat = ".jpg"
                        }
                    }
                }
            }

            GroupBox {
                title: qsTr("婚姻关系模式")
                Layout.fillWidth: true
                
                RowLayout {
                    RadioButton {
                        id: modernRadio
                        text: qsTr("现代模式（妻/前妻）")
                        checked: settingsManager ? settingsManager.marriageMode === "modern" : true
                        onClicked: {
                            settingsManager.setMarriageMode("modern")
                        }
                    }
                    RadioButton {
                        id: ancientRadio
                        text: qsTr("古代模式（妻/前妻/妾）")
                        checked: settingsManager ? settingsManager.marriageMode === "ancient" : false
                        onClicked: {
                            settingsManager.setMarriageMode("ancient")
                        }
                    }
                }
            }

            GroupBox {
                title: qsTr("照片显示模式")
                Layout.fillWidth: true
                visible: false
                
                RowLayout {
                    RadioButton {
                        id: withPhotoRadio
                        text: qsTr("有照片模式")
                        checked: settingsManager ? settingsManager.photoDisplay === "with_photo" : true
                        onClicked: {
                            settingsManager.setPhotoDisplay("with_photo")
                        }
                    }
                    RadioButton {
                        id: noPhotoRadio
                        text: qsTr("无照片模式")
                        checked: settingsManager ? settingsManager.photoDisplay === "no_photo" : false
                        onClicked: {
                            settingsManager.setPhotoDisplay("no_photo")
                        }
                    }
                }
            }
            
            // 添加重置按钮
            Button {
                text: qsTr("恢复默认设置")
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    settingsManager.resetToDefaults()
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    Component {
        id: feedbackPage
        ColumnLayout {
            anchors.fill: parent

            // 居中的大按钮
            Button {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: 300
                Layout.preferredHeight: 60
                text: qsTr("前往 GitHub 提交反馈")
                font.pixelSize: 16
                
                onClicked: {
                    Qt.openUrlExternally("https://github.com/wangeasy6/KinshipDiagram/issues/new")
                }
                
                background: Rectangle {
                    radius: 5
                    color: parent.down ? "#1565C0" : (parent.hovered ? "#1976D2" : "#2196F3")
                }
                
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // 组件列表
    property list<Component> settingComponents: [
        sysSettings,
        mapSettings,
        feedbackPage
    ]
}
