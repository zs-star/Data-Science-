
---CREATE TABLE TRANSACTIONS

CREATE TABLE transactions  (
    Sender INT NOT NULL,
	Receiver INT NOT NULL,
	Amount INT NOT NULL,
    Transaction_date VARCHAR (25) NOT NULL,
	);
--- ÝNSERT VALUES

INSERT INTO transactions (Sender, Receiver, Amount,Transaction_date)VALUES (5,2,10,'2-12-20')
INSERT INTO transactions (Sender, Receiver, Amount,Transaction_date)VALUES (1,3,15,'2-13-20')
INSERT INTO transactions (Sender, Receiver, Amount,Transaction_date)VALUES (2,1,20,'2-13-20')
INSERT INTO transactions (Sender, Receiver, Amount,Transaction_date)VALUES (2,3,25,'2-14-20')
INSERT INTO transactions (Sender, Receiver, Amount,Transaction_date)VALUES (3,1,20,'2-15-20')
INSERT INTO transactions (Sender, Receiver, Amount,Transaction_date)VALUES (3,2,15,'2-15-20')
INSERT INTO transactions (Sender, Receiver, Amount,Transaction_date)VALUES (1,4,5,'2-16-20')

----- DESÝRED OUTPUT
WITH
sum_sender as
(select Sender,sum(Amount) as amount_Sender
from transactions
group by Sender ),
sum_receiver as
(select Receiver,sum(Amount) as amount_Receiver
from transactions
group by Receiver)
select coalesce(Sender,Receiver) as User_ ,coalesce(amount_Receiver,0)-coalesce(amount_Sender,0) as Net_change
from sum_sender
full outer join sum_receiver
on Sender=Receiver
order by Net_change DESC