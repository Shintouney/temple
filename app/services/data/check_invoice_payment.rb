/* component: message */
.lia-panel-message,
.lia-message-view-display {
    background: transparent;
    border-radius: 0;
    border: 0;
    box-shadow: none;
    padding: 0;

    &.lia-message-view-recent-posts-item {
        margin-bottom: $custom-space-base;
    }
}

/* message view - bg, border, subject */
.lia-message-view-wrapper {
    .lia-message-view-display>.lia-quilt {
        .lia-mark-empty {
            display: none;
        }

        /* subject */
        .MessageSubject {
            .message-subject {
                .lia-message-read {
                    font-weight: normal;
                }

                .lia-message-unread {
                    font-weight: 600;
                }

                .page-link,
                .lia-message-subject h5 {
                    color: $custom-color-foreground;
                    font-family: $custom-type-font-titles;
                    font-size: $custom-type-size-xlarge;
                    font-weight: inherit;

                    @include media(phone) {
                        font-size: $custom-type-size-xlarge;
                    }
                }
            }
        }
    }
}

/* custom message layout message post*/
.lia-quilt-layout-custom-message {
    @include boxShadow();
    background: $custom-color-background;
    border-radius: $custom-border-radius-base;
    padding: $custom-space-base;

    .lia-quilt-row-message-header-top {
        text-align: right;

        @include media(phone) {
            text-align: left;
        }
        
        /* message option*/
        .lia-menu-navigation-wrapper {
            float: none;
            position: relative;
            right: initial;
            top: inherit;
            
            .default-menu-option {
                @include li-icon-svg($li-svg-ellipsis-v, $size: $custom-type-size-large, $color: $custom-color-foreground-light,$pseudo: after);
                
                &:before {
                    display: none;
                }

                &:after {
                    display: inline-block;
                    vertical-align: middle;
                    width: auto !important;
                }
            }
        
            @include media(tablet-and-up) {
                position: relative;
                right: 0;
                top: 0;
            }
        }        
    }

    .lia-quilt-row-message-header-top {
        .custom-reply & {
            padding-bottom: $custom-space-small + $custom-space-xsmall;
        }
    }

    .lia-quilt-column-message-header-bottom-right {
        text-align: right;
    }

    /* subject */
    .MessageSubjectIcons {
        display: block;
        float: none;
        text-align: left;
    }

    .lia-component-message-view-widget-subject {
        display: block !important;
    
        .verified-icon,
        span.lia-fa {
            display: none;
        }
    
        .message-subject {
            .lia-message-read,
            .lia-message-unread {
    
                .lia-link-navigation,
                .lia-message-subject {
                    font-size: $custom-type-size-xxlarge;;
                    font-weight: bold;
                    line-height: normal;
                    margin-bottom: 0;
    
                    @include media(phone-only) {
                        font-size: $custom-type-size-xxlarge;
                    }
                }
            }
        }
    }
    
    .lia-message-author-with-avatar {
        margin-bottom: $custom-space-base;

        .lia-component-author-avatar {
            padding-right: 0;
        }

        .lia-user-name-link,
        .lia-message-author-rank {
            font-size: $custom-type-size-base;
        }

        .lia-message-author-rank:before {
            content: "|";
            padding: 0 $custom-space-xsmall;
        }
    }

    .lia-quilt-row-message-main {
        .lia-thread-topic & {
            border-top: 0;
            padding-top: 0;
        }
    }

    /* message body */
    .lia-message-body-content {
        font-size: $custom-type-size-base;
 
        .lia-panel-feedback-banner-safe {
            display: none;
        }
    }

    .AddMessageTags {
        font-weight: 600;
    }

    /* attachment */
    .lia-component-attachments {
        margin-bottom: $custom-space-small;
    
        .lia-fa-icon:before {
            content: "\f0c6";
            font-family: "FontAwesome";
            font-size: $custom-type-size-base;
            vertical-align: middle;
        }
    
        .attachment-link {
            color: $custom-color-foreground;
            font-size: $custom-type-size-small;
        }
    }

    .lia-quilt-row-message-main {
        padding-bottom: $custom-space-base;
        padding-top: $custom-space-base;
    }

    /* footer - kudo, reply, accepted solution etc. */
    .lia-quilt-row-message-footer {
        margin-top: $custom-space-base + $custom-space-small;
    
        .lia-quilt-column-left {
            width: 20%;
        }
    
        .lia-quilt-column-right {
            width: 80%;
        }
    
        .lia-quilt-column-left,
        .lia-quilt-column-right {
            display: inline-block;
            vertical-align: middle;
        }

        .lia-quilt-column-right {
            .lia-quilt-column-alley-right {
                text-align: right;
            }
        }
    
        .lia-component-share-button,
        .lia-button-wrapper,
        .lia-button-group {
            display: inline-block;
            margin-right: $custom-space-small;

            @include media(phone) {
                display: block;
                width: 100%;
            }
        }
    
        .lia-button-wrapper.lia-button-wrapper.lia-component-quick-reply-button {
            margin-right: $custom-space-xsmall;
        }
    
        .lia-component-share-button {
            .lia-button-wrapper {
                margin-right: 0;
            }
        }
    
        @include media(phone) {
            .lia-quilt-column-left,
            .lia-quilt-column-right {
                display: block;
                margin-bottom: $custom-space-small;
                text-align: left;
                width: 100%;
            }
    
            .lia-quilt-column-right {
                .lia-component-share-button,
                .lia-button-wrapper,
                .lia-button-wrapper a {
                    display: block;
                    width: 100%;
                    margin-bottom: $custom-space-small;
                }
            }
        }
    }
    
    /* moderation btn */
    .lia-quilt-row-message-moderation {
        @include media(tablet-and-up) {
            margin-top: $custom-space-base;
        }
    
        @include media(phone) {
            .lia-button-wrapper {
                display: block;
                width: 100%;
    
                a {
                    display: block;
                    width: 100%
                }
            }
        }

        .lia-component-message-view-widget-escalate-message-button {
            display: inline-block;
            margin-bottom: $custom-space-base;
        }
    }

    .lia-list-row-thread-solved.lia-accepted-solution & {
        border: 4px solid $custom-color-uncertified-solution;
        position: relative;
    }

    .lia-list-row-thread-solved.lia-accepted-solution.certified-sfr & {
        border: 4px solid $custom-color-solution;
        position: relative;
    }

    .custom-thread-status.custom-thread-sfr-certified {
        color: $custom-color-safe;
        display: inline-block;
        font-size: $custom-type-size-base;
        float: left;
        text-align: left;
    }
    .lia-list-row-thread-solved.lia-accepted-solution {
      
    }  


}
