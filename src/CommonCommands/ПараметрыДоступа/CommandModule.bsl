
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	ПараметрыОткрытия = Новый Структура("ОбъектДоступа", ПараметрКоманды);
	ОткрытьФорму("ОбщаяФорма.ФормаРедактированияПараметровДоступа", ПараметрыОткрытия, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно, ПараметрыВыполненияКоманды.НавигационнаяСсылка);
	
КонецПроцедуры
