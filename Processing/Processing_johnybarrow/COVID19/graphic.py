import matplotlib.pyplot as plt

PATH = input("Имя графика: ")
if PATH:
    PATH = "logs/" + PATH
else:
    PATH = "logs/log5"

with open(f"{PATH}.csv") as f:
    text = f.readlines()[1:]

array = []

for i in text:
    array.append(list(map(int, i.split(','))))

array = tuple(zip(*array))

plt.title("График зависимости Covid-19")
plt.xlabel("Время")
plt.ylabel("Количество частиц")
plt.grid()

plt.figure(figsize=(12, 12))

plt.subplot(2, 1, 2)
plt.fill_between(array[0], array[1], color='red', label='Больные', alpha=0.6)
plt.fill_between(array[0], array[2], color='black', label='Умершие', alpha=0.7)
plt.title("График зависимости зараженных частиц от времени")
plt.xlabel("Время")
plt.ylabel("Количество частиц")
plt.grid()
plt.legend()

plt.subplot(2, 2, 1)
plt.fill_between(array[0], array[3], color='green', label='Выздоровевшие', alpha=0.6)
plt.title("График зависимости выздоровевших частиц от времени")
plt.xlabel("Время")
plt.ylabel("Количество выздоровевших")
plt.grid()
plt.legend()

plt.subplot(2, 2, 2)
plt.fill_between(array[0], array[4], color='red', label='Заболеваний', alpha=0.5)
plt.title("График зависимости заболеваний частиц от времени")
plt.xlabel("Время")
plt.ylabel("Количество заболеваний")
plt.grid()
plt.legend()

plt.savefig(f'{PATH}.png')
