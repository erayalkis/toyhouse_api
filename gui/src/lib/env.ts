export const parseEnvString = (envStr: string): Record<string, string> => {
  const lines = envStr.split("\n");

  const envCfg: Record<string, string> = {};

  lines.forEach((line) => {
    const split = line.split("=");
    const key = split[0];
    const value = split[1];

    envCfg[key] = value;
  });

  return envCfg;
};
