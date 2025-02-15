IF EXISTS ( SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id(N'[dbo].[LockUserFunds]') 
                   and OBJECTPROPERTY(id, N'IsProcedure') = 1 )
BEGIN
    DROP PROCEDURE [dbo].[LockUserFunds]
END


CREATE PROCEDURE LockUserFunds
    @UserID INT,
    @CurrencyCodeId INT,
    @AmountToLock MONEY
AS
BEGIN
    UPDATE Wallets 
    SET LockedBalance = LockedBalance + @AmountToLock
    WHERE UserID = @UserID 
    AND CurrencyCodeId = @CurrencyCodeId
    AND AvailableBalance >= @AmountToLock
    
    IF @@ROWCOUNT = 0
        RAISERROR ('Insufficient funds available to lock', 16, 1)END
GO