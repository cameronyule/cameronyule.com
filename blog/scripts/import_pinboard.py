import json
import os
import re
import argparse
from datetime import datetime


def slugify(text):
    """
    Converts text to a URL-friendly slug.
    """
    text = text.lower()
    text = re.sub(r"[^\w\s-]", "", text)  # Remove non-word chars
    text = re.sub(r"[\s_-]+", "-", text)  # Replace spaces/underscores with single dash
    text = re.sub(r"^-+|-+$", "", text)  # Remove leading/trailing dashes
    return text


def import_bookmarks(json_file_path, output_dir, required_tag=None):
    """
    Imports bookmarks from a JSON file and creates Hugo markdown files.
    Only imports bookmarks that contain the specified required_tag, if provided.
    """
    if not os.path.exists(json_file_path):
        print(f"Error: JSON input file not found at '{json_file_path}'")
        return

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created output directory: {output_dir}")

    with open(json_file_path, "r", encoding="utf-8") as f:
        bookmarks = json.load(f)

    print(f"Found {len(bookmarks)} bookmarks in {json_file_path}")
    if required_tag:
        print(f"Filtering bookmarks to include only those with tag: '{required_tag}'")

    imported_count = 0
    skipped_count_filter = 0

    for bookmark in bookmarks:
        href = bookmark.get("href", "")
        description = bookmark.get("description", "No Description")
        extended = bookmark.get("extended", "")
        time_str = bookmark.get("time", "")
        tags_str = bookmark.get("tags", "")

        # Check if the bookmark contains the required tag
        current_tags = [tag.strip() for tag in tags_str.split(" ") if tag.strip()]
        if required_tag and required_tag not in current_tags:
            skipped_count_filter += 1
            continue  # Skip this bookmark if it doesn't have the required tag

        # Format date for Hugo front matter
        try:
            # Parse the time string (e.g., "2025-06-26T10:10:02Z")
            dt_object = datetime.strptime(time_str, "%Y-%m-%dT%H:%M:%SZ")
            hugo_date = dt_object.strftime(
                "%Y-%m-%dT%H:%M:%S+00:00"
            )  # Ensure timezone offset for Hugo
            file_date_prefix = dt_object.strftime(
                "%Y-%m-%d"
            )  # Format for filename prefix
        except ValueError:
            hugo_date = datetime.now().strftime("%Y-%m-%dT%H:%M:%S+00:00")
            file_date_prefix = datetime.now().strftime("%Y-%m-%d")
            print(
                f"Warning: Could not parse date '{time_str}'. Using current date and time for '{description}'."
            )

        # Prepare tags as a YAML list, ensuring each tag is properly JSON-escaped
        # Use current_tags which has already been processed
        tags_escaped = [json.dumps(tag) for tag in current_tags]
        tags_yaml = f"[{', '.join(tags_escaped)}]" if tags_escaped else "[]"

        # Generate filename slug
        base_slug = slugify(description)
        if not base_slug:  # Fallback if description slugifies to empty
            base_slug = "bookmark"

        # Combine date prefix and slug for the filename
        filename_base = f"{file_date_prefix}-{base_slug}"
        filename = f"{filename_base}.md"
        file_path = os.path.join(output_dir, filename)

        # Construct front matter
        # Use YAML literal block scalar (|) for title and link to avoid any escape issues.
        # This will place the content on the next line, indented.
        front_matter = f"""---
title: |
  {description}
date: {hugo_date}
draft: false
tags: {tags_yaml}
link: |
  {href}
categories: []
---
"""
        # Add extended content to the body if it exists
        content_body = extended.strip()

        full_content = f"{front_matter}\n{content_body}\n"

        # Always write the file to ensure problematic files are fixed.
        # If a file with this name already exists, it will be overwritten.
        with open(file_path, "w", encoding="utf-8") as md_file:
            md_file.write(full_content)
        print(f"Created/Updated: {file_path}")
        imported_count += 1

    print(f"\nImport complete. Successfully imported {imported_count} bookmarks.")
    if required_tag:
        print(f"Skipped {skipped_count_filter} bookmarks due to tag filter.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Import bookmarks from a Pinboard JSON export into Hugo markdown files.",
        formatter_class=argparse.RawTextHelpFormatter,  # For better formatting of default values
    )
    parser.add_argument(
        "json_file",
        type=str,
        help="Path to the Pinboard JSON export file (e.g., blog/data/pinboard_export.json)",
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default="blog/content/bookmarks",
        help="""Directory where the new bookmark markdown files will be created.
(default: %(default)s)""",
    )
    parser.add_argument(
        "--tag",
        type=str,
        default="cy-bookmark",
        help="""Only import bookmarks that include this specific tag.
(default: %(default)s)""",
    )

    args = parser.parse_args()

    import_bookmarks(args.json_file, args.output_dir, args.tag)
