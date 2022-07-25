class Account:
    def __init__(self, val):
        self.__category = val['분류']
        self.__ammount = val['금액']
        self.__date = val['결제일']
        self.__content = val['내용']
    
    @property
    def category(self):
        return self.__category
    
    @property
    def ammount(self):
        return self.__ammount
    
    @property
    def date(self):
        return self.__date

    @property
    def content(self):
        return self.__content
