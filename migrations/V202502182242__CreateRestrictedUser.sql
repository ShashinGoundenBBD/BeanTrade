

IF EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = 'RestrictedUser')
BEGIN
    DROP LOGIN RestrictedUser;
END;

CREATE LOGIN RestrictedUser WITH PASSWORD = '${RESTRICTED_USER_PASSWORD}';
USE BeanTrade;

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'RestrictedUser')
BEGIN
    DROP USER RestrictedUser;
END;


CREATE USER RestrictedUser FOR LOGIN RestrictedUser;

GRANT SELECT, INSERT, UPDATE, REFERENCES, EXECUTE ON DATABASE::BeanTrade TO RestrictedUser;