import type {
  GalleryImage,
  ImageMetadata,
  OwnershipLog,
  ToyhouseProfile,
} from "./interfaces/toyhouse";

import { useMessageStore } from "@/stores/message";
import { backendConfig } from "@/config/backendConfig";
import { useErrorStore } from "@/stores/error";
import { useQueueStore } from "@/stores/queue";
import { useOptionsStore } from "@/stores/options";
import { invoke } from "@tauri-apps/api";

export const fetchCharacterGallery = async (id: string) => {
  const { setError, clearError } = useErrorStore();
  const { clearMessage } = useMessageStore();
  const backendUrl = backendConfig.backendUrl;

  try {
    const characterJSONString = await fetch(
      `${backendUrl}/character/${id}/gallery`
    );
    // Parse received json string into a POJO
    const res = await characterJSONString.json();
    return res;
  } catch (e) {
    clearMessage();
    setError("Something went wrong while fetching the gallery!");
    console.error(e);
    setTimeout(() => {
      clearError();
    }, 1200);
  }
};

export const fetchCharacterDetails = async (id: string) => {
  const { setError, clearError } = useErrorStore();
  const { clearMessage } = useMessageStore();
  const backendUrl = backendConfig.backendUrl;

  try {
    const characterJSONString = await fetch(
      `${backendUrl}/character/${id}/details`
    );
    // Parse received json string into a POJO
    const res = await characterJSONString.json();
    return res;
  } catch (e) {
    clearMessage();
    setError("Something went wrong while fetching the character!");
    console.error(e);
    setTimeout(() => {
      clearError();
    }, 1200);
  }
};

export const fetchCharacterOwnershipLogs = async (id: string) => {
  const { setError, clearError } = useErrorStore();
  const { clearMessage } = useMessageStore();
  const backendUrl = backendConfig.backendUrl;

  try {
    const characterJSONString = await fetch(
      `${backendUrl}/character/${id}/ownership`
    );
    // Parse received json string into a POJO
    const res = await characterJSONString.json();
    return res;
  } catch (e) {
    clearMessage();
    setError("Something went wrong while fetching ownership logs!");
    console.error(e);
    setTimeout(() => {
      clearError();
    }, 1200);
  }
};

const createLogsText = async (id: string) => {
  const { ownership } = await fetchCharacterOwnershipLogs(id);
  let logsFileContent = "";

  ownership.forEach((log: OwnershipLog) => {
    console.log(log);
    const parsedDate = log.date.replace("\n", "").trim();
    const parsedContent = log.description
      .replace("\n", "")
      .replace("\n\n", " ")
      .trim();

    console.log(parsedContent);
    const completeRow = `${parsedDate} --- ${parsedContent}\n`;

    logsFileContent += completeRow;
  });

  return logsFileContent;
};

const createCreditsText = (credits: ToyhouseProfile[][]) => {
  let artistsText = "";

  credits.forEach((artists, idx) => {
    artistsText += `\n${idx}: `;
    artists.forEach(
      (artist) => (artistsText += `[${artist.name}, ${artist.link}] `)
    );
    artistsText += "\n";
  });

  return artistsText;
};

const createMetadataText = (metadata: ImageMetadata[]) => {
  let mtdtText = "";

  metadata.forEach((mtd, idx) => {
    mtdtText += `\n${idx}: \n\tDate: ${mtd.date}\n`;
    if (mtd.description) {
      mtdtText += "\tDescription: ";
      const parsed_description = mtd.description.replace("Caption", "").trim();
      mtdtText += parsed_description;
      mtdtText += "\n";
    } else {
      mtdtText += "\tDescription: N/A \n";
    }

    mtdtText += `\tTagged Characters: `;
    mtd.tagged_characters.forEach(
      (char) => (mtdtText += `[${char.name}, ${char.link}] `)
    );
    mtdtText += "\n";
  });

  return mtdtText;
};

export const downloadCharacter = async (id: string) => {
  if (!id) return null;
  const { setMessage, clearMessage } = useMessageStore();
  const { setError, clearError } = useErrorStore();
  const { opts } = useOptionsStore();

  setMessage("Fetching gallery...");
  const characterObj = await fetchCharacterGallery(id);
  console.log(characterObj);
  if (!characterObj.gallery || characterObj.error) {
    clearMessage();
    setError("Character is invalid!");
    setTimeout(() => {
      clearError();
    }, 1200);
    return;
  }

  const gallery: Array<GalleryImage> = characterObj.gallery;
  setMessage("Extracting links from gallery...");
  const links = gallery.map((img) => img.link);
  setMessage("Extracting credits from gallery...");
  const creditsArray = gallery.map((img) => img.artists);
  const credits = createCreditsText(creditsArray);
  setMessage("Extracting metadata from gallery...");
  const metadataArray = gallery.map((img) => img.image_metadata);
  const metadata = createMetadataText(metadataArray);

  let logs;
  if (opts.downloadOwnerLogs) {
    setMessage("Fetching ownership logs...");
    logs = await createLogsText(id);
  }

  console.log(
    "LINKS",
    links,
    "CREDITS",
    credits,
    "METADATA",
    metadata,
    "LOGS",
    logs
  );

  setMessage("Downloading gallery...");
  await invoke("download_character", { id, links, credits, metadata, logs });
  setMessage("Gallery downloaded!");
  setTimeout(() => {
    clearMessage();
  }, 1200);
};

export const downloadQueue = async () => {
  const { queue, removeCharacter } = useQueueStore();

  for (const char of queue) {
    await downloadCharacter(char.id);
    removeCharacter(char.id);
  }
};
