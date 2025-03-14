import * as mplTokenMetadata from "@metaplex-foundation/mpl-token-metadata";
const { Metadata, updateMetadata, transferToken } = mplTokenMetadata;
import { Connection, PublicKey } from "@solana/web3.js";

export async function updateNFTPrice(mintId, newPrice) {
  const connection = new Connection("https://api.devnet.solana.com");
  const mintAddress = new PublicKey(mintId);

  try {
    console.log(`🔄 Mise à jour du prix du NFT : ${mintId}`);

    // Récupérer les métadonnées existantes
    const metadataPDA = await Metadata.getPDA(mintAddress);
    const metadata = await Metadata.load(connection, metadataPDA);

    // Modifier les métadonnées pour inclure le nouveau prix
    const updatedMetadata = {
      ...metadata.data,
      attributes: metadata.data.attributes.map((attr) =>
        attr.trait_type === "Prix"
          ? { ...attr, value: `${newPrice} FCFA` }
          : attr
      ),
    };

    await updateMetadata({
      connection,
      mint: mintAddress,
      data: updatedMetadata,
    });

    console.log("✅ Prix mis à jour avec succès !");
  } catch (error) {
    console.error("❌ Erreur lors de la mise à jour du NFT :", error.message);
  }
}

export async function transferNFT(vendeurId, acheteurId, mintId) {
  const connection = new Connection("https://api.devnet.solana.com");
  const mintAddress = new PublicKey(mintId);

  try {
    console.log(
      `🔄 Transfert du NFT ${mintId} de ${vendeurId} à ${acheteurId}`
    );

    // Récupérer les adresses des wallets des utilisateurs
    const [vendeur] = await db.query(
      "SELECT walletAddress FROM personne WHERE id = ?",
      [vendeurId]
    );
    const [acheteur] = await db.query(
      "SELECT walletAddress FROM personne WHERE id = ?",
      [acheteurId]
    );

    if (vendeur.length === 0 || acheteur.length === 0) {
      throw new Error("❌ Wallet non trouvé.");
    }

    const vendeurWallet = new PublicKey(vendeur[0].walletAddress);
    const acheteurWallet = new PublicKey(acheteur[0].walletAddress);

    // Transférer le NFT
    await transferToken({
      connection,
      mint: mintAddress,
      from: vendeurWallet,
      to: acheteurWallet,
      amount: 1,
    });

    console.log("✅ NFT transféré avec succès !");
  } catch (error) {
    console.error("❌ Erreur lors du transfert du NFT :", error.message);
  }
}
