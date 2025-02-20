
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CancelOrder]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[CancelOrder]
GO
CREATE PROCEDURE [dbo].[CancelOrder]
    @OrderID BIGINT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
		DECLARE @CancelledStatusId INT = (SELECT StatusId FROM OrderStatuses WHERE [Status] = 'Cancelled');

        UPDATE Orders
        SET StatusId = @CancelledStatusId  
        WHERE OrderID = @OrderID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        RAISERROR('An error occurred while cancelling the order: %s', 16, 1);
    END CATCH
END