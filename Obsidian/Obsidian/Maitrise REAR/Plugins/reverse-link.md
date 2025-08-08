<%*
// Récupérer le nom de la note actuellement ouverte (Note A)
const noteA = app.workspace.getActiveFile();
if (!noteA) {
    tp.user.prompt("Aucune note ouverte actuellement. Ouvrez une note et réessayez.");
    return;
}
const noteAName = noteA.basename;

// Demander à l'utilisateur de sélectionner ou de saisir le nom de la note B
const noteBName = await tp.system.suggester(
    (file) => file.basename, // Afficher les noms des fichiers
    app.vault.getMarkdownFiles(), // Liste des fichiers Markdown
    { placeholder: "Sélectionnez ou tapez le nom de la note B" }
);

if (!noteBName) {
    tp.user.prompt("Aucune note sélectionnée. Opération annulée.");
    return;
}

// Créer un lien vers la note A dans la note B
const noteB = app.vault.getAbstractFileByPath(noteBName.path);
if (!noteB) {
    tp.user.prompt("La note B n'existe pas. Opération annulée.");
    return;
}

// Ajouter le lien vers la note A dans la note B
await app.vault.append(noteB, `\n[[${noteAName}]]`);
-%>
Lien vers [[<% noteAName %>]] ajouté dans [[<% noteBName.basename %>]].



