--8259A Programlanabilir kesme denetleyicisi (PIC)
--Hakan Murat Aksut 313979 1.ogretim
--Emirhan Kuy 330106 1.ogretim
--NOT bu tasarimda Sirali �ncelik baz alinmistir(IR0 en oncelikli IR7 en az gibi)
--NOT bu tasarimda CPU'nun NOT(INTA) darbeleri kesmeye hemen cevap veridigi d�s�n�lerek yapilmistir
--NOT bu tasarimda CAS uclarinin aktiflesmesi g�z ard? edilmistir.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ePIC is
    Port (
	s : in std_logic; --SAAT 	
	--MASTER KAYDEDICILER VE CIKISLARI
	MASTER_IRR : inout std_logic_vector(7 downto 0):="00000000";
	MASTER_ISR : inout std_logic_vector(7 downto 0):="00000000";
	MASTER_IMR : inout std_logic_vector(7 downto 0):="00000000";
	MASTER_INT : inout std_logic;
	--SLAVE1 KAYDEDICILER VE CIKISLARI
	SLAVE1_IRR : inout std_logic_vector(7 downto 0):="00000000";
	SLAVE1_ISR : inout std_logic_vector(7 downto 0):="00000000";
	SLAVE1_IMR : inout std_logic_vector(7 downto 0):="00000000";
	SLAVE1_INT : inout std_logic;
	--SLAVE2 KAYDEDICILER VE CIKISLARI
	SLAVE2_IRR : inout std_logic_vector(7 downto 0):="00000000";
	SLAVE2_ISR : inout std_logic_vector(7 downto 0):="00000000";
	SLAVE2_IMR : inout std_logic_vector(7 downto 0):="00000000";
	SLAVE2_INT : inout std_logic;
        --MASTER IR0-7 GIRISLERI
	MASTER_IR_giris : inout std_logic_vector(7 downto 0):="00000000";	--bu giri?lerin amac? simulasyonda sonuclar? gorebilmek
	--SLAVE1 IR8-15 GIRISLERI						-- IR0-IR23 harici cihazlardan gelen kesme isteklerini
	SLAVE1_IR_giris : inout std_logic_vector(7 downto 0):="00000000";	--simulasyonda buradan verecegiz.
	--SLAVE2 IR16-23 GIRISLERI
	SLAVE2_IR_giris : inout std_logic_vector(7 downto 0):="00000000");
end ePIC;

  architecture Behv of ePIC is
	 --MASTER IR0-7 GIRISLERI
	signal MASTER_IR :  std_logic_vector(7 downto 0);	
	--SLAVE1 IR8-15 GIRISLERI				
	signal SLAVE1_IR : std_logic_vector(7 downto 0);
	--SLAVE2 IR16-23 GIRISLERI
	signal SLAVE2_IR :  std_logic_vector(7 downto 0);
  begin
     process(s)
		
	begin
		--simulasyonda degerlerimizi gormek icin verecegimiz degerleri atiyoruz.
		MASTER_IR <=MASTER_IR_giris;
		SLAVE1_IR <=SLAVE1_IR_giris;
		SLAVE2_IR <=SLAVE2_IR_giris;

		for i in SLAVE1_IR'low to SlAVE1_IR'high loop
			if (SLAVE1_IR(i)='1') then				-- en �ncelikli cihazin IR'sini aldik
		   		for j in (i+1) to SLAVE1_IR'high loop		-- geri kalan t�m bitleri low'a setledik
					SLAVE1_IR(j)<='0' ;
					
		 	   	end loop;		  
			  exit; 
			end if;
		end loop;
		
			if(SLAVE1_IMR /="00000000") then				--maske kaydedicisi 00000000'dan farkliysa
    				for i in SLAVE1_IMR'low to SlAVE1_IMR'high loop		--hangi giris maskelenmisse buluruz ve
					if(SLAVE1_IMR(i)='1') then			--maskelenmis bite karsilik d�sen IR girisin 0'a setleriz
					SLAVE1_IR(i)<='0';				--b�ylece istedigimiz cihazi maskeleyebiliriz.
					end if;
				end loop;
			end if;
 
		SLAVE1_IRR <= SLAVE1_IR;			--kesme gelen ilgili cihaza karsilik gelen bitin IRR kaydedicisi setlenir
		
		if(SLAVE1_IR="00000000") then
			SLAVE1_INT <='0';
		else 
			SLAVE1_INT <='1';
		end if;						--Slave1'in master'a bagli INT cikisi HIGH olur.							
		
		SLAVE1_ISR <= SLAVE1_IRR;			--en �ncelikli IRR biti ISR kaydedicisine aktarilir
		MASTER_IR(0) <= SLAVE1_INT;			--kesme istegi masterin Ir0 bacagina iletilir c�nk� slave1 masterin 0 numarali bacagina bagli
	
	
      
		for i in SLAVE2_IR'low to SlAVE2_IR'high loop
			if (SLAVE2_IR(i)='1') then			-- en �ncelikli cihazin IR'sini aldik
			   for j in (i+1) to SLAVE2_IR'high loop	-- geri kalan t�m bitleri low'a setledik
				SLAVE2_IR(j)<='0';
			    end loop;
			  exit;
			end if;
		end loop;
		
			if(SLAVE2_IMR /="00000000") then				--maske kaydedicisi 00000000'dan farkliysa
    				for i in SLAVE2_IMR'low to SlAVE2_IMR'high loop		--hangi giris maskelenmisse buluruz ve
					if(SLAVE2_IMR(i)='1') then			--maskelenmis bite karsilik d�sen IR girisin 0'a setleriz
					SLAVE2_IR(i)<='0';				--b�ylece istedigimiz cihazi maskeleyebiliriz.
					end if;
				end loop;
			end if;
 
	
		SLAVE2_IRR <= SLAVE2_IR;			--kesme gelen ilgili cihaza karsilik gelen bitin IRR kaydedicisi setlenir
	
		if(SLAVE2_IR="00000000") then
			SLAVE2_INT <='0';
		else 
			SLAVE2_INT <='1';
		end if;						--Slave2'in master'a bagli INT cikisi HIGH olur.							
		SLAVE2_ISR <= SLAVE2_IRR;			--en �ncelikli IRR biti ISR kaydedicisine aktarilir
		MASTER_IR(4) <= SLAVE2_INT;			--kesme istegi masterin Ir4 bacagine iletilir c�nk� slave2 masterin 4 numarali bacagina bagli.
	
	
        	for i in MASTER_IR'low to MASTER_IR'high loop
			if (MASTER_IR(i)='1') then			-- en �ncelikli cihazin IR'sini aldik
			   for j in (i+1) to MASTER_IR'high loop	-- geri kalan t�m bitleri low'a setledik
				MASTER_IR(j)<='0';
		 	   end loop;
			  exit;
			end if;
		end loop;

				if(MASTER_IMR /="00000000") then				--maske kaydedicisi 00000000'dan farkliysa
    				for i in MASTER_IMR'low to MASTER_IMR'high loop		--hangi giris maskelenmisse buluruz ve
					if(MASTER_IMR(i)='1') then			--maskelenmis bite karsilik d�sen IR girisin 0'a setleriz
					MASTER_IR(i)<='0';				--b�ylece istedigimiz cihaz? maskeleyebiliriz.
					end if;
				end loop;
			end if;
 

		MASTER_IRR <= MASTER_IR;			--kesme gelen ilgili cihaza karsilik gelen bitin IRR kaydedicisi setlenir
		if(MASTER_IR="00000000") then
			MASTER_INT <='0';
		else 
			MASTER_INT <='1';			--kesme icin INT cikisi aktif hala getirildi
		end if;						--Master INT ile CPU'a kesme istedigi gonderir
		
	
		--CPU INTA'a ilk darbe g�nderir
		--CAS0-CAS2 cikislarini aktif hale getirir.
		MASTER_ISR <= MASTER_IRR;			--en �ncelikli IRR biti ISR kaydedicisine aktarilir.

		--CPU INTA'aya ikinci darbeyi g�nderir
		--8 bit uzunlugundaki kesme vektor numaras? veri yoluna(d7-d0) koyulur.
		--kesme islemi tamamlanir.
		
		
		
	
	end process ;
			
		--yeni bir kesme icin IRR kaydediciler sifirlanir
		MASTER_IRR <="00000000";			-- ilgili IRR biti 0'a cekilir.
		SLAVE1_IRR <="00000000";			-- Slave1'in IRR kaydedicisi sifirlanir.
		SLAVE2_IRR <="00000000";			-- Slave2'in IRR kaydedicisi sifirlanir.


   end Behv;