from abc import *

class IaccountRepository(metaclass=ABCMeta):
    @abstractmethod
    def save(self, account):
        pass
    @abstractmethod
    def load(self):
        pass
     