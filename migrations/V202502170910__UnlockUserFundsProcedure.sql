CREATE PROCEDURE UnlockUserFunds
    @UserID INT,
    @CurrencyCodeId INT,
    @AmountToUnlock MONEY
AS
BEGIN
    UPDATE Wallets 
    SET LockedBalance = LockedBalance - @AmountToUnlock, Balance = Balance + @AmountToUnlock
    WHERE UserID = @UserID 
    AND CurrencyCodeId = @CurrencyCodeId
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR ('Invalid amount to unlock or insufficient funds', 16, 1);
    END
END
GO