import pandas as pd
from sklearn.neighbors import NearestNeighbors
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import MinMaxScaler
import streamlit as st


df = pd.read_csv('https://raw.githubusercontent.com/isnardynicolas/streamlit/main/film_oriented.csv')

st.sidebar.markdown("<h1 style='text-align: center;'>Système de recommandations de films 🎬</h1>", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.markdown("<h6 style='text-align: center;'>pour le compte du</h6>", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)

image_url = "https://github.com/isnardynicolas/streamlit/blob/main/logo-cinema-noir.png?raw=true"
st.sidebar.image(image_url, use_column_width=True)

st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)
st.sidebar.write(" ", unsafe_allow_html=True)



st.sidebar.markdown("<h6 style='text-align: center;'>by</h6>", unsafe_allow_html=True)

image_url2 = "https://github.com/isnardynicolas/streamlit/blob/d229c268ae6b02c40212af4c60aa07aa24cd36ef/logo_480.png?raw=true"
st.sidebar.image(image_url2, use_column_width=True)


df.drop("Unnamed: 0", inplace=True, axis=1)

df.runtimeMinutes = pd.to_numeric(df.runtimeMinutes, errors='coerce')
df.dropna(subset="runtimeMinutes", inplace=True)

df = df.loc[df.genre_1 != "\\N"]
df.reset_index(drop=True)

genres = set(df['genre_1']).union(set(df['genre_2'])).union(set(df.genre_3))
for genre in genres:
    df[genre] = df.apply(lambda row: 1 if genre in [row['genre_1'], row['genre_2'], row["genre_3"]] else 0, axis=1)
#st.write(df.columns)
df.drop(df.columns[16], axis=1, inplace=True)


st.markdown("<h3 style='text-align: center;'>Manque d'inspiration pour votre soirée cinéma ? Nous sommes là pour vous aider !</h3>", unsafe_allow_html=True)
st.write(" ", unsafe_allow_html=True)
image_url3 = "https://media.giphy.com/media/13C8uU4ZKi9CW4/giphy.gif"
st.image(image_url3, use_column_width=True)
st.write(" ", unsafe_allow_html=True)
st.write(" ", unsafe_allow_html=True)
st.write(" ", unsafe_allow_html=True)
film_choisi = st.text_input("Entrez le titre du film de votre choix 😊")
film_choisi = film_choisi.lower()

df["title_lower"] = df.title.str.lower()

if film_choisi in df.title_lower.values:
    # Recommandtion films du meme real

    director_choisi = df.loc[df["title_lower"] == film_choisi, "primaryName"].item()
    # On créer un df avec les enregistrement qui ont pour PrimaryName le nom du directeur du film choisi
    df_ml_director = df.loc[df["primaryName"] == director_choisi, :]

    X_director = df_ml_director.select_dtypes("number")

    scaler = StandardScaler()
    scaler.fit(X_director)
    X_scaled = scaler.transform(X_director)

    norm = MinMaxScaler()
    norm.fit(X_scaled)
    X_norm = norm.transform(X_scaled)
    st.write(" ", unsafe_allow_html=True)
    st.write(" ", unsafe_allow_html=True)    
    st.write(" ", unsafe_allow_html=True)
    st.write(" ", unsafe_allow_html=True)
    n_neighbors_director = st.slider("Choisissez le nombre de recommandations que vous souhaitez :", 1, len(df_ml_director), len(df_ml_director))
    modelKNN_directors = NearestNeighbors(n_neighbors=n_neighbors_director).fit(X_norm)

    


    z_director = df_ml_director.loc[df_ml_director.title_lower == film_choisi, X_director.columns]

    z_scaled = scaler.transform(z_director)

    z_norm = norm.transform(z_scaled)

    neighbor = modelKNN_directors.kneighbors(z_norm)
    df_result_director = df_ml_director.iloc[neighbor[1][0]].rename(columns = {"title": "Titre", "primaryName": "Réalisateur", "genre_1": "Genre 1",
                                                                            "genre_2": "Genre 2", "genre_3": "Genre 3", "startYear": "Année de sortie",
                                                                            "runtimeMinutes": "Durée", "averageRating": "Note moyenne"})

    def concat_genres(row):
        genres = []
        if pd.notnull(row["Genre 1"]):
            genres.append(str(row["Genre 1"]))
        if pd.notnull(row["Genre 2"]):
            genres.append(str(row["Genre 2"]))
        if pd.notnull(row["Genre 3"]):
            genres.append(str(row["Genre 3"]))
        return ", ".join(genres)

    st.markdown("<h5 style='text-align: center;'>Nous vous proposons ces films du/de la même réalisateur/trice :</h5>", unsafe_allow_html=True)
    df_result_director["Genres"] = df_result_director.apply(concat_genres, axis=1)
    df_result_director["Année de sortie"] = df_result_director["Année de sortie"].astype(str).str.replace(",", "")
    df_result_director["Durée"] = df_result_director["Durée"].apply(lambda x: str(round(x//60)) + "h" + str(round(x%60)) + "m")
    st.dataframe(df_result_director.loc[:, ["Titre", "Réalisateur", "Genres","Année de sortie", "Durée", "Note moyenne"]].set_index("Titre"))


    # ### Recommandation films du meme genre 1

    genre_choisi = df.loc[df["title_lower"] == film_choisi, "genre_1"].item()
    df_ml_genre = df.loc[df["genre_1"] == genre_choisi, :]

    X_genre = df_ml_genre.select_dtypes("number")

    scaler = StandardScaler()
    scaler.fit(X_genre)
    X_scaled = scaler.transform(X_genre)

    norm = MinMaxScaler()
    norm.fit(X_scaled)
    X_norm = norm.transform(X_scaled)

    st.write(" ", unsafe_allow_html=True)
    st.write(" ", unsafe_allow_html=True)    
    st.write(" ", unsafe_allow_html=True)
    st.write(" ", unsafe_allow_html=True)
    n_neighbors_genre = st.slider("Choisissez le nombre de recommandations que vous souhaitez :", 1, 30, 30)
    modelKNN_genre = NearestNeighbors(n_neighbors=n_neighbors_genre).fit(X_norm)

    z_genre = df_ml_genre.loc[df_ml_genre.title_lower == film_choisi, X_genre.columns]

    z_scaled = scaler.transform(z_genre)

    z_norm = norm.transform(z_scaled)

    neighbor = modelKNN_genre.kneighbors(z_norm)
    df_result_genre = df_ml_genre.iloc[neighbor[1][0]].rename(columns = {"title": "Titre", "primaryName": "Réalisateur", "genre_1": "Genre 1",
                                                                            "genre_2": "Genre 2", "genre_3": "Genre 3", "startYear": "Année de sortie",
                                                                            "runtimeMinutes": "Durée", "averageRating": "Note moyenne"})

    st.markdown("<h5 style='text-align: center;'>Ces films du même genre vous plairons certainement :</h5>", unsafe_allow_html=True)
    df_result_genre["Genres"] = df_result_genre.apply(concat_genres, axis=1)
    df_result_genre["Année de sortie"] = df_result_genre["Année de sortie"].astype(str).str.replace(",", "")
    df_result_genre["Durée"] = df_result_genre["Durée"].apply(lambda x: str(round(x//60)) + "h" + str(round(x%60)) + "m")
    st.dataframe(df_result_genre.loc[:, ["Titre", "Réalisateur", "Genres","Année de sortie", "Durée", "Note moyenne"]].set_index("Titre"))

    # ### Recommandation films de la meme année

    year_choisi = df.loc[df["title_lower"] == film_choisi, "startYear"].item()
    df_ml_year = df.loc[df["startYear"] == year_choisi, :]

    X_year = df_ml_year.select_dtypes("number")

    scaler = StandardScaler()
    scaler.fit(X_year)
    X_scaled = scaler.transform(X_year)

    norm = MinMaxScaler()
    norm.fit(X_scaled)
    X_norm = norm.transform(X_scaled)

    st.write(" ", unsafe_allow_html=True)
    st.write(" ", unsafe_allow_html=True)    
    st.write(" ", unsafe_allow_html=True)
    st.write(" ", unsafe_allow_html=True)
    n_neighbors_year = st.slider("Choisissez le nombre de recommandation que vous souhaitez :", 1, 30, 30)
    modelKNN_year = NearestNeighbors(n_neighbors=n_neighbors_year).fit(X_norm)

    z_year = df_ml_year.loc[df_ml_year.title_lower == film_choisi, X_year.columns]

    z_scaled = scaler.transform(z_year)

    z_norm = norm.transform(z_scaled)

    neighbor = modelKNN_year.kneighbors(z_norm)
    df_result_year = df_ml_year.iloc[neighbor[1][0]].rename(columns = {"title": "Titre", "primaryName": "Réalisateur", "genre_1": "Genre 1",
                                                                            "genre_2": "Genre 2", "genre_3": "Genre 3", "startYear": "Année de sortie",
                                                                            "runtimeMinutes": "Durée", "averageRating": "Note moyenne"})

    st.markdown("<h5 style='text-align: center;'>Nous vous recommandons ces films sortis la même année :</h5>", unsafe_allow_html=True)
    df_result_year["Genres"] = df_result_year.apply(concat_genres, axis=1)
    df_result_year["Année de sortie"] = df_result_year["Année de sortie"].astype(str).str.replace(",", "")
    df_result_year["Durée"] = df_result_year["Durée"].apply(lambda x: str(round(x//60)) + "h" + str(round(x%60)) + "m")
    st.dataframe(df_result_year.loc[:, ["Titre", "Réalisateur", "Genres","Année de sortie", "Durée", "Note moyenne"]].set_index("Titre"))

elif film_choisi == "":
    st.write("")
else:
    st.write("Ce titre de film n'existe pas")
