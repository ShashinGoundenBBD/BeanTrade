CREATE UNIQUE INDEX [UQ_Wallet_User_Currency] ON [Wallets] ("UserID", "CurrencyCodeId")
GO

CREATE UNIQUE INDEX [UQ_Inventory_User_Product] ON [Inventory] ("UserID", "BeanID")
GO

CREATE INDEX [IX_Orders_UserID_Status] ON [Orders] ("UserID", "StatusId")
GO

CREATE INDEX [IX_Orders_Matching] ON [Orders] ("BeanID", "OrderTypeId", "StatusId", "PricePerBean")
GO

CREATE INDEX [IX_Trades_BuyOrder] ON [Trades] ("BuyOrderID")
GO

CREATE INDEX [IX_Trades_SellOrder] ON [Trades] ("SellOrderID")
GO

CREATE UNIQUE INDEX [UQ_Trade_Orders] ON [Trades] ("BuyOrderID", "SellOrderID")
GO

CREATE INDEX [IX_Transactions_Wallet] ON [Transactions] ("WalletID")
GO

CREATE INDEX [IX_Transactions_WalletStatus] ON [Transactions] ("WalletID", "TransactionTypeId")
GO