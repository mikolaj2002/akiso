import pygame
import math
import time

# Inicjalizacja Pygame
pygame.init()

# Ustawienie rozmiarów okna
screen_width, screen_height = 640, 480
screen = pygame.display.set_mode((screen_width, screen_height))

# Ustawienie tytułu okna
pygame.display.set_caption("Animacja z Pygame")

# Wczytanie tła
#background_image = pygame.image.load("tlo.jpg").convert()

# Ustawienie współrzędnych środka okręgu
center_x, center_y = screen_width // 2, screen_height // 2

# Ustawienie promienia okręgu
radius = 100

# Ustawienie początkowego kąta
angle = 0

# Ustawienie szybkości animacji (w stopniach na klatkę)
speed = 1

# Pętla główna programu
points = []
running = True
while running:
    # Pobranie wszystkich zdarzeń wygenerowanych przez użytkownika
    for event in pygame.event.get():
        # Jeśli użytkownik naciśnie przycisk "Zamknij", to zakończ pętlę
        if event.type == pygame.QUIT:
            running = False

    # Wyliczenie współrzędnych końca odcinka
    x = center_x + radius * math.cos(math.radians(angle))
    y = center_y + radius * math.sin(math.radians(angle))
    
    points += [[x, y]]
    
    # Rysowanie tła
    screen.fill('black')

    # Rysowanie odcinka
    pygame.draw.line(screen, (255, 0, 0), (center_x, center_y), (x, y), 2)
    
    for point in points:
      pygame.draw.circle(screen, (255, 0, 0), [point[0], point[1]], 2, 0)

    # Aktualizacja okna
    pygame.display.update()

    # Zwiększenie kąta
    angle += speed
    
    time.sleep(0.05)

# Zakończenie Pygame
pygame.quit()
