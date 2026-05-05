import pandas as pd
import statsmodels.formula.api as smf

df = pd.read_csv('../Database/propertyDatabase_MLR.csv')
print(df.head())
print(df.shape)

print(df['price'].describe())
print(df['price'].dtype)

model = smf.ols('price ~ bedrooms + bathrooms + parking_space', data=df).fit()
print(model.summary())