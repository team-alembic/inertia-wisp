import React from "react";

export interface IconProps {
  size?: "sm" | "md" | "lg" | number;
  className?: string;
  color?: string;
}

const getIconSize = (size: IconProps["size"]) => {
  if (typeof size === "number") return size;
  
  switch (size) {
    case "sm":
      return 16;
    case "md":
      return 20;
    case "lg":
      return 24;
    default:
      return 20;
  }
};

const IconWrapper: React.FC<IconProps & { children: React.ReactNode }> = ({
  size = "md",
  className = "",
  color = "currentColor",
  children,
}) => {
  const iconSize = getIconSize(size);
  
  return (
    <svg
      className={`w-${iconSize === 16 ? "4" : iconSize === 20 ? "5" : "6"} h-${iconSize === 16 ? "4" : iconSize === 20 ? "5" : "6"} ${className}`}
      fill={color}
      viewBox="0 0 20 20"
      width={iconSize}
      height={iconSize}
    >
      {children}
    </svg>
  );
};

export const UsersIcon: React.FC<IconProps> = (props) => (
  <IconWrapper {...props}>
    <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z" />
  </IconWrapper>
);

export const PostsIcon: React.FC<IconProps> = (props) => (
  <IconWrapper {...props}>
    <path d="M2 5a2 2 0 012-2h7a2 2 0 012 2v4a2 2 0 01-2 2H9l-3 3v-3H4a2 2 0 01-2-2V5z" />
    <path d="M15 7v2a4 4 0 01-4 4H9.828l-1.766 1.767c.28.149.599.233.938.233h2l3 3v-3h2a2 2 0 002-2V9a2 2 0 00-2-2h-1z" />
  </IconWrapper>
);

export const UserIcon: React.FC<IconProps> = (props) => (
  <IconWrapper {...props}>
    <path
      fillRule="evenodd"
      d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
      clipRule="evenodd"
    />
  </IconWrapper>
);

export const CheckCircleIcon: React.FC<IconProps> = (props) => (
  <IconWrapper {...props}>
    <path
      fillRule="evenodd"
      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
      clipRule="evenodd"
    />
  </IconWrapper>
);

export const CheckIcon: React.FC<IconProps> = (props) => (
  <IconWrapper {...props}>
    <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
  </IconWrapper>
);

export const TeamIcon: React.FC<IconProps> = (props) => (
  <IconWrapper {...props}>
    <path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3z" />
  </IconWrapper>
);

export const MailIcon: React.FC<IconProps> = (props) => (
  <IconWrapper {...props}>
    <path d="M4 4a2 2 0 00-2 2v8a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2H4zm12 4l-6 4-6-4h12z" />
  </IconWrapper>
);

export const RefreshIcon: React.FC<IconProps> = (props) => (
  <IconWrapper {...props}>
    <path
      fillRule="evenodd"
      d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z"
      clipRule="evenodd"
    />
  </IconWrapper>
);

// Export all icons as a collection for easier importing
export const Icons = {
  Users: UsersIcon,
  Posts: PostsIcon,
  User: UserIcon,
  CheckCircle: CheckCircleIcon,
  Check: CheckIcon,
  Team: TeamIcon,
  Mail: MailIcon,
  Refresh: RefreshIcon,
};