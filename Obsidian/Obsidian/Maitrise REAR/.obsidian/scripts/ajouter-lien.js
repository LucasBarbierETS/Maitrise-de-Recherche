module.exports = async function (params) {
    // Récupérer la note actuellement ouverte (Note A)
    const noteA = app.workspace.getActiveFile();
    if (!noteA) {
        new Notice("Aucune note ouverte actuellement. Ouvrez une note et réessayez.");
        return;
    }
    const noteAName = noteA.basename;

    // Récupérer la note sur laquelle vous avez cliqué droit (Note B)
    const noteB = params.vault.getAbstractFileByPath(params.file.path);
    if (!noteB) {
        new Notice("Impossible de récupérer la note sélectionnée.");
        return;
    }

    // Ajouter un lien vers la note A dans la note B
    await app.vault.append(noteB, `\n[[${noteAName}]]`);
    new Notice(`Lien vers [[${noteAName}]] ajouté dans ${noteB.basename}.`);
};