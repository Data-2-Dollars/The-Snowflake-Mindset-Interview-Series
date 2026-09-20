-- winget install --id ShiningLight.OpenSSL.Light --source winget


-- & "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" version



-- & "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" genrsa -out rsa_key.p8 2048
-- & "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" rsa -in rsa_key.p8 -pubout -out rsa_key.pub


-- ((Get-Content rsa_key.pub) | Where-Object { $_ -notmatch '-----' }) -join ''


ALTER USER DATA2DOLLARS
SET RSA_PUBLIC_KEY='';

describe user DATA2DOLLARS;
