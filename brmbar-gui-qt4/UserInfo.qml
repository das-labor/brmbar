import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    property string name: ""
    property string dbid: ""
    property string negbalance: ""

    Text {
        id: item_name
        x: 65
        y: 156
        width: 337
        height: 160
        color: "#ffffff"
        text: parent.name
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 0.768 * 60
    }

    Text {
        id: text3
        x: 411
        y: 156
        height: 160
        width: 548
        color: "#ffff7c"
        text: parent.negbalance
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 0.768 * 122
    }

    BarcodeInput {
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined") {
                status_text.setStatus("Unknown barcode", "#ff4444")
                return
            }
            if (acct.acctype === "recharge") {
                loadPage("ChargeCredit", { "username": name, "userdbid": dbid, "amount": acct.amount })
                return
            }

            loadPageByAcct(acct)
        }
    }

    BarButton {
        id: charge_credit
        x: 65
        y: 838
        width: 360
        text: "Charge"
        fontSize: 0.768 * 60
        onButtonClick: {
            loadPage("ChargeCredit", { "username": name, "userdbid": dbid })
        }
    }

    BarButton {
        id: cancel
        x: 855
        y: 838
        width: 360
        text: "Main Screen"
        onButtonClick: {
            loadPage("MainPage")
        }
    }
}
