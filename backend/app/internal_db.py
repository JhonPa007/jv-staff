# Simulación de Base de Datos en Memoria
class InMemoryDB:
    def __init__(self):
        # Estado inicial (Simulamos que ya trabajó algo en el mes)
        self.total_production = 1500.00
        self.pending_commission = 120.00
        self.appointments_completed = 15

    def add_sale(self, service_price: float, commission_percent: float):
        commission = service_price * (commission_percent / 100)
        
        self.total_production += service_price
        self.pending_commission += commission
        self.appointments_completed += 1
        
        return {
            "earned": commission,
            "new_total": self.pending_commission
        }

# Instancia global (Singleton)
db = InMemoryDB()
