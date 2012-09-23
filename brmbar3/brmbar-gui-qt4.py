#!/usr/bin/python3

import sys
import psycopg2

from PySide import QtCore, QtGui, QtDeclarative

import brmbar


class ShopAdapter(QtCore.QObject):
	""" Interface between QML and the brmbar package """
	def __init__(self):
		QtCore.QObject.__init__(self)

	@QtCore.Slot(str, result='QVariant')
	def barcodeInput(self, barcode):
		""" Evaluate barcode received on input

		Normally, we would return just the account object, but
		passing that to QML appears to be very non-trivial.
		Therefore, we construct a map that we can pass around easily.
		We return None on unrecognized barcode. """
		barcode = str(barcode)
		if barcode and barcode[0] == "$":
			credits = {'$02': 20, '$05': 50, '$10': 100, '$20': 200, '$50': 500, '$1k': 1000}
			credit = credits[barcode]
			if credit is None:
				return None
			return { "acctype": "recharge", "amount": str(credit)+".00" }
		acct = brmbar.Account.load_by_barcode(db, barcode)
		if acct is None:
			return None
		if acct.acctype == 'debt':
			map = acct.__dict__.copy()
			map["balance"] = str(acct.balance())
			map["negbalance"] = str(-acct.balance())
			map["negbalance_str"] = acct.negbalance_str()
			return map
		elif acct.acctype == "inventory":
			buy, sell = acct.currency.rates(currency)
			map = acct.__dict__.copy()
			map["price"] = str(sell)
			return map
		else:
			return None

	@QtCore.Slot('QVariant', 'QVariant', result='QVariant')
	def sellItem(self, itemid, userid):
		user = brmbar.Account.load(db, id = userid)
		shop.sell(item = brmbar.Account.load(db, id = itemid), user = user)
		return user.negbalance_str()

	@QtCore.Slot('QVariant', result='QVariant')
	def sellItemCash(self, itemid):
		shop.sell_for_cash(item = brmbar.Account.load(db, id = itemid))

	@QtCore.Slot('QVariant', 'QVariant', result='QVariant')
	def chargeCredit(self, credit, userid):
		user = brmbar.Account.load(db, id = userid)
		shop.add_credit(credit = credit, user = user)
		return user.negbalance_str()

	@QtCore.Slot(result='QVariant')
	def balance_cash(self):
		return shop.cash.balance_str()
	@QtCore.Slot(result='QVariant')
	def balance_profit(self):
		return shop.profits.balance_str()
	@QtCore.Slot(result='QVariant')
	def balance_inventory(self):
		return shop.inventory_negbalance_str()
	@QtCore.Slot(result='QVariant')
	def balance_credit(self):
		return shop.credit_negbalance_str()

db = psycopg2.connect("dbname=brmbar")
shop = brmbar.Shop.new_with_defaults(db)
currency = shop.currency


app = QtGui.QApplication(sys.argv)
view = QtDeclarative.QDeclarativeView()

ctx = view.rootContext()
ctx.setContextProperty('shop', ShopAdapter())

view.setSource('brmbar-gui-qt4/main.qml')

view.show()
app.exec_()