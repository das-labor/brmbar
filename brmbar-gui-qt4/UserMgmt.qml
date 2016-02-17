import QtQuick 1.1

Item {
    id: page
    anchors.fill: parent

    property variant user_list_model

    BarcodeInput {
        color: "#00ff00" /* just for debugging */
        onAccepted: {
            var acct = shop.barcodeInput(text)
            text = ""
            if (typeof(acct) == "undefined") {
                status_text.setStatus("Unknown barcode", "#ff4444")
                return
            }
            if (acct.acctype !== "debt") {
                loadPageByAcct(acct)
                return
            }
	    /* TODO: This should be UserEdit when implemented. */
            loadPage("Withdraw", { username: acct["name"], userdbid: acct["id"] })
        }
    }

    Item {
	id: user_list_container
        x: 65
        y: 166
        width: 1155
        height: 656

	ListView {
	    id: user_list
	    anchors.fill: parent
	    clip: true
	    delegate: Item {
		x: 5
		height: 80

		Text {
		    text: modelData.name
		    anchors.verticalCenter: parent.verticalCenter
		    color: "#ffffff"
		    font.pixelSize: 0.768 * 46
		}

		Text {
		    anchors.verticalCenter: parent.verticalCenter
		    x: 556
		    width: 254
		    color: "#ffff7c"
		    text: modelData.negbalance_str
		    horizontalAlignment: Text.AlignRight
		    font.pixelSize: 0.768 * 46
		}

		BarButton {
		    anchors.verticalCenter: parent.verticalCenter
		    x: 856
		    width: 240
		    height: 68
		    text: "Withdraw"
		    fontSize: 0.768 * 46
		    onButtonClick: {
			loadPage("Withdraw", { username: modelData.name, userdbid: modelData.id })
		    }
		}
	    }
	    model: user_list_model
	}

	BarScrollBar {
	    id: user_list_scrollbar
	    anchors.right: parent.right
	    anchors.rightMargin: 0
	    flickableItem: user_list
	}
    }

    BarButton {
        id: add_user
        x: 65
        y: 838
        width: 360
        text: "Add User"
        fontSize: 0.768 * 60
	btnColor: "#666666"
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

    Component.onCompleted: {
	user_list_model = shop.userList()
    }
}
