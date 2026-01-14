CREATE TABLE [dbo].[orders] (

	[order_id] int NULL, 
	[customer_id] int NULL, 
	[order_date] date NULL, 
	[status] varchar(16) NULL, 
	[credit_card_amount] int NULL, 
	[coupon_amount] int NULL, 
	[bank_transfer_amount] int NULL, 
	[gift_card_amount] int NULL, 
	[amount] int NULL
);